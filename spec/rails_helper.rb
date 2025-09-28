ENV["RAILS_ENV"] ||= "test"

require "spec_helper"

# Load the internal Rails application
require File.expand_path('internal/config/environment', __dir__)

# Load RSpec Rails
require 'rspec/rails'

# Shoulda Matchers
require 'shoulda/matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Basic RSpec configuration
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

# Prepare database via schema (self-contained for this engine)
ActiveRecord::Migration.verbose = false
schema_path = File.join(__dir__, 'internal', 'db', 'schema.rb')
load schema_path if File.exist?(schema_path)

# Load seed data for tests
seed_path = File.join(__dir__, 'internal', 'db', 'seeds.rb')
load seed_path if File.exist?(seed_path)
