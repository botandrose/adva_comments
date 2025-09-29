require 'rails_helper'

RSpec.describe 'Activities::CommentObserver', type: :model do
  let(:site)    { Site.first }
  let(:section) { Section.first }
  let(:article) { Article.first }

  before do
    skip('rails-observers not available') unless defined?(ActiveRecord::Observer)
    skip('observer class missing') unless defined?(Activities::CommentObserver)
    if ActiveRecord::Base.respond_to?(:observers=)
      ActiveRecord::Base.observers = 'Activities::CommentObserver'
      ActiveRecord::Base.instantiate_observers if ActiveRecord::Base.respond_to?(:instantiate_observers)
    end
  end

  it "logs 'created' on new comment" do
    created_activity = nil
    allow(Activity).to receive(:new).and_wrap_original do |m, *args|
      created_activity = m.call(*args)
      allow(created_activity).to receive(:save!).and_return(true)
      created_activity
    end

    Comment.create!(
      site: site,
      section: section,
      commentable: article,
      author_name: 'Observer Test',
      author_email: 'observer@example.com',
      body: 'hello'
    )

    expect(created_activity).not_to be_nil
    expect(Array(created_activity.actions)).to include('created')
  end
end
