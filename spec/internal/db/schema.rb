ActiveRecord::Schema.define do
  # Sites table (subset of fields needed by tests)
  create_table :sites, force: true do |t|
    t.string  :name
    t.string  :host
    t.string  :title
    t.string  :timezone
    t.integer :comment_age
    t.string  :comment_filter
    t.timestamps
  end

  add_index :sites, :host

  # Sections table (awesome_nested_set-ready)
  create_table :sections, force: true do |t|
    t.string     :type
    t.references :site
    t.integer    :parent_id
    t.integer    :lft, null: false, default: 0
    t.integer    :rgt, null: false, default: 0
    t.string     :path
    t.string     :permalink
    t.string     :title
    t.integer    :comment_age, default: 0
    t.string     :content_filter
    t.text       :permissions
    t.datetime   :published_at
  end

  add_index :sections, [:site_id, :permalink]

  # Users table (subset)
  create_table :users, force: true do |t|
    t.string   :first_name,  limit: 40
    t.string   :last_name,   limit: 40
    t.string   :email,       limit: 100
    t.string   :password_hash, limit: 40
    t.string   :password_salt, limit: 40
    t.boolean  :anonymous, default: false
    t.datetime :verified_at
    t.timestamps
  end

  # Contents table (STI base for Article)
  create_table :contents, force: true do |t|
    t.references :site
    t.references :section
    t.string     :type, limit: 20
    t.string     :title
    t.string     :permalink
    t.text       :body
    t.text       :excerpt
    t.text       :excerpt_html
    t.text       :body_html

    t.references :author, polymorphic: true
    t.string     :author_name, limit: 40
    t.string     :author_email, limit: 40
    t.string     :author_homepage

    t.integer    :version
    t.string     :filter
    t.integer    :comment_age, default: 0
    t.string     :cached_tag_list
    t.integer    :assets_count, default: 0

    t.integer    :parent_id
    t.integer    :lft, null: false, default: 0
    t.integer    :rgt, null: false, default: 0

    t.datetime   :published_at
    t.timestamps
  end

  add_index :contents, [:section_id, :permalink]

  # Categories and categorizations (minimal to satisfy associations)
  create_table :categories, force: true do |t|
    t.references :section
    t.integer    :parent_id
    t.integer    :lft, null: false, default: 0
    t.integer    :rgt, null: false, default: 0
    t.string     :title
    t.string     :path
    t.string     :permalink
  end

  create_table :categorizations, force: true do |t|
    t.string     :categorizable_type
    t.integer    :categorizable_id
    t.references :category
  end

  # Comments table
  create_table :comments, force: true do |t|
    t.references :site, null: false
    t.references :section, null: false
    t.references :commentable, polymorphic: true, null: false
    t.references :author, polymorphic: true
    t.string :author_name, limit: 40
    t.string :author_email, limit: 40
    t.string :author_homepage
    t.text :body
    t.text :body_html
    t.integer :approved, default: 0, null: false
    t.timestamps
  end

  add_index :comments, [:commentable_type, :commentable_id]
  add_index :comments, [:site_id, :approved]

  # Activities table (for notifications)
  create_table :activities, force: true do |t|
    t.references :site
    t.references :section
    t.references :object, polymorphic: true
    t.string :type
    t.timestamps
  end

  # Counters table (for has_counter)
  create_table :counters, force: true do |t|
    t.references :owner, polymorphic: true
    t.string  :name, limit: 25
    t.integer :count, default: 0
  end
end
