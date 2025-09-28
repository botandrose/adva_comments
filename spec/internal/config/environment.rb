ENV['RAILS_ENV'] ||= 'test'

require_relative 'application'

Internal::Application.initialize!
