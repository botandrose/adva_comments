module ActiveRecord
  module HasCounter
    class << self
      def included(base)
        base.extend ActMacro
      end
    end

    module ActMacro
      def has_counter(*names)
        options = names.extract_options!
        callbacks = options[:callbacks] || { after_create: :increment!, after_destroy: :decrement! }
        [:after_create, :after_destroy, :after_save].each do |k|
          next unless options.key?(k)
          value = options[k]
          if value == false || value.nil?
            callbacks.delete(k)
          else
            callbacks[k] = value
          end
        end

        class_attribute :"update_counters"
        self.update_counters ||= {}

        names.each do |name|
          counter_name = :"#{name}_counter"
          owner_name = options[:as] || self.name.demodulize.underscore
          class_name = options[:class_name] || name

          define_method :"#{name}_count" do
            send(counter_name).count
          end

          has_one counter_name, -> { where(name: name) },
                                as: :owner,
                                class_name: "Counter",
                                dependent: :delete

          # create the counter lazily upon first access
          class_eval <<-code, __FILE__, __LINE__
            prepend Module.new {
              def #{counter_name}(force_reload = false)
                reload_#{counter_name} if force_reload
                result = super()
                if result.nil?
                  Counter.create!(:owner => self, :name => #{name.to_s.inspect})
                  reload_#{counter_name}
                  result = super()
                end
                result
              end
            }
          code

          # Wire up the counted class so that it updates our counter, basically
          # an anonymous callback/observer pattern
          target = class_name.to_s.classify.constantize
          owner_klass = self
          callbacks.keys.each do |callback|
            target.send callback do
              record = self
              owner = record.send(owner_name) if record.respond_to?(owner_name)
              # do not update the counter when counter's owner (e.g. article) is not frozen (deleted)
              if owner_klass === owner && !owner.frozen? && record.class == target
                method = callbacks[callback]
                method = method.call(record) if Proc === method
                counter = owner.send(counter_name) if method
                counter.send method if counter && method
              end
            end
          end
        end
      end
    end
  end
end
