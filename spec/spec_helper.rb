require 'simplecov'
require 'simplecov-html'

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/lib/adva_comments/version.rb'

  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Libraries', 'lib'

  formatter SimpleCov::Formatter::HTMLFormatter
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
