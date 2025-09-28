"$LOAD_PATH" << File.expand_path('../lib', __dir__)

require 'simplecov'
  SimpleCov.profiles.define 'gem_default' do
    add_filter '/spec/'
    add_filter '/db/'
    add_filter 'lib/has_counter/version.rb'
    track_files 'lib/**/*.rb'
  end
  SimpleCov.coverage_dir File.expand_path('../coverage', __dir__)
  SimpleCov.minimum_coverage 100
SimpleCov.start 'gem_default'

ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'rspec'
require 'logger'
require 'active_record'
require 'active_support'
require 'active_support/core_ext'

# Use SQLite3 for an isolated, file-based DB
ActiveRecord::Base.logger = Logger.new(File.join(__dir__, 'has_counter.spec.log'))
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.join(__dir__, 'has_counter.sqlite3.db')
)

# Load gem components
require 'has_counter'

# Activate the gem's extension on ActiveRecord
ActiveRecord::Base.include ActiveRecord::HasCounter

# Ensure tables exist for tests
unless Counter.table_exists?
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define(version: 1) do
    create_table :counters, force: true do |t|
      t.references :owner, polymorphic: true
      t.string     :name, limit: 25
      t.integer    :count, default: 0
    end
  end
end

module CounterSpec
  class Comment < ActiveRecord::Base
    self.table_name = 'comments'

    belongs_to :content
    after_save    :update_commentable
    after_destroy :update_commentable

    unless table_exists?
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define(version: 1) do
        create_table :comments, force: true do |t|
          t.references :content
          t.text :text
          t.integer :approved
        end
      end
    end

    def unapproved?
      !approved?
    end

    # Compatibility across AR versions
    def approved_changed?
      if respond_to?(:saved_change_to_approved?)
        saved_change_to_approved?
      elsif respond_to?(:attribute_changed?)
        attribute_changed?(:approved)
      else
        false
      end
    end

    def just_approved?
      approved? && approved_changed?
    end

    def just_unapproved?
      !approved? && approved_changed?
    end

    def update_commentable
      content.after_comment_update(self)
    end
  end

  class Content < ActiveRecord::Base
    self.table_name = 'contents'

    has_many :comments

    has_counter :comments,
                class_name: 'CounterSpec::Comment'

    has_counter :approved_comments,
                class_name: 'CounterSpec::Comment',
                after_create: false,
                after_destroy: false

    def after_comment_update(comment)
      method = if comment.frozen? && comment.approved?
        :decrement!
      elsif comment.just_approved?
        :increment!
      elsif comment.just_unapproved?
        :decrement!
      end
      approved_comments_counter.send(method) if method
    end

    unless table_exists?
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define(version: 1) do
        create_table :contents, force: true do |t|
          t.string :title, limit: 50
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should]
  end
end
