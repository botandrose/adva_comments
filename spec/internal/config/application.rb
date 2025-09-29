require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "adva"
require "adva_comments"
begin
  require 'rails/observers/active_record/observer'
rescue LoadError
end

module Internal
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    if Rails::VERSION::MAJOR >= 8
      config.load_defaults 8.0
    else
      config.load_defaults 7.2
    end
    config.eager_load = false
    config.hosts.clear
    config.secret_key_base = "test_secret_key_base_please_change"
    config.active_support.deprecation = :stderr

    # Disable asset pipeline in tests
    config.assets.enabled = false

    # Enable observers for tests when available
    if defined?(ActiveRecord::Observer)
      config.active_record.observers = 'Activities::CommentObserver'
    end
  end
end
