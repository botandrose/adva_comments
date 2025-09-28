require "active_support/core_ext/time"

# Create test data for specs
if Site.count.zero?
  site = Site.create!(
    name: "Test Site",
    title: "Test Site Title",
    host: "test-site.com",
    comment_filter: 'textile_filter'
  )

  section = Section.create!(
    site: site,
    title: "Test Section",
    permalink: "test-section",
    comment_age: 0
  )

  user = User.create!(
    first_name: "Test",
    last_name: "User",
    email: "test@example.com",
    password_hash: "hash",
    password_salt: "salt",
    verified_at: Time.now
  )

  article = Article.create!(
    site: site,
    section: section,
    title: "Test Article",
    body: "Test article body",
    author: user,
    published_at: Time.parse('2008-01-01 12:00:00')
  )

  Comment.create!(
    site: site,
    section: section,
    commentable: article,
    author_name: "Test Commenter",
    author_email: "commenter@example.com",
    body: "Test comment body",
    approved: true
  )
end
