if defined?(Comment)
  module Activities
    class CommentObserver < ActiveRecord::Observer
      observe :comment

      class_attribute :activity_attributes, :activity_conditions
      self.activity_attributes = []
      self.activity_conditions = [[:created, :new_record?], [:deleted, :frozen?]]

      class << self
        def logs_activity(options = {})
          self.activity_attributes += options[:attributes] if options[:attributes]
          yield Configurator.new(self) if block_given?
        end
      end

      class Configurator
        def initialize(klass)
          @klass = klass
        end

        def method_missing(name, options)
          options.assert_valid_keys :if
          @klass.activity_conditions << [name, options[:if]]
        end
      end

      logs_activity do |log|
        log.edited :if => [:body_changed?, {:not => :new_record?}]
        log.approved :if => [:approved_changed?, :approved?]
        log.unapproved :if => [:approved_changed?, :unapproved?]
      end

      def before_save(record)
        prepare_activity_logging(record)
      end

      def after_save(record)
        log_activity(record)
      end

      def after_destroy(record)
        prepare_activity_logging(record)
        log_activity(record)
      end

      protected

      def prepare_activity_logging(record)
        record.instance_variable_set :@activity, initialize_activity(record)
      end

      def log_activity(record)
        activity = record.instance_variable_get :@activity
        if activity && !activity.actions.empty?
          activity.object = record
          if record.respond_to?(:author_name)
            activity.author_name = record.author_name
            activity.author_email = record.author_email if record.respond_to?(:author_email)
            activity.author_homepage = record.author_homepage if record.respond_to?(:author_homepage)
          elsif record.respond_to?(:author) && record.author.respond_to?(:name)
            activity.author_name = record.author.name
          end
          # Satisfy author association validation if present
          if activity.respond_to?(:author=)
            author_obj = User.first
            activity.author = author_obj if author_obj
          end
          activity.save!
        end
        record.instance_variable_set :@activity, nil
      end

      def initialize_activity(record)
        Activity.new(:actions => collect_actions(record),
                     :object_attributes => collect_activity_attributes(record)).tap do |activity|
          activity.site = record.commentable.site
          activity.section = record.commentable.section
          # cache author details instead of associating
          if record.respond_to?(:author_name)
            activity.author_name = record.author_name
            activity.author_email = record.author_email if record.respond_to?(:author_email)
            activity.author_homepage = record.author_homepage if record.respond_to?(:author_homepage)
          elsif record.respond_to?(:author) && record.author.respond_to?(:name)
            activity.author_name = record.author.name
          end
        end
      end

      def collect_actions(record)
        activity_conditions.collect do |name, conditions|
          name.to_s if conditions_satisfied?(record, conditions)
        end.compact
      end

      def conditions_satisfied?(record, conditions)
        conditions = conditions.is_a?(Array) ? conditions : [conditions]
        conditions.collect do |condition|
          condition_satisfied?(record, condition)
        end.inject(true){|a, b| a && b }
      end

      def condition_satisfied?(record, condition)
        case condition
        when Symbol then !!record.send(condition)
        when Hash then
          condition.collect do |key, condition|
            case key
            when :not then !record.send(condition)
            else raise 'not implemented'
            end
          end.inject(false){|a, b| a || b }
        end
      end

      def collect_activity_attributes(record)
        Hash[*activity_attributes.map do |attribute|
          [attribute.to_s, case attribute
                           when Symbol then record.send attribute
                           when Proc   then record.attribute.call(self)
                           end]
        end.flatten].tap do |attrs|
          # Override with comment-specific attributes
          clone_attrs = if record.respond_to?(:clone_attributes, true)
                          record.send(:clone_attributes)
                        else
                          record.attributes
                        end
          comment_attrs = clone_attrs.slice 'commentable_id', 'body', 'author_name', 'author_email', 'author_url'
          type = record.commentable.has_attribute?('type') ? record.commentable['type'] : record.commentable_type
          comment_attrs.update('commentable_type' => type, 'commentable_title' => record.commentable.title)
          attrs.merge!(comment_attrs)
        end
      end
    end
  end
else # stub constant to make zeitwerk eagerload happy
  module Activities
    class CommentObserver; end
  end
end
