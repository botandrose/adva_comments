ENV['RAILS_ENV'] ||= 'test'

require_relative 'application'

Internal::Application.initialize!

# Ensure observers are instantiated when configured
if defined?(ActiveRecord::Observer) && ActiveRecord::Base.respond_to?(:instantiate_observers)
  ActiveRecord::Base.instantiate_observers
end
