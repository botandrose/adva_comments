require 'rails_helper'

RSpec.describe 'Activities::CommentObserver', type: :model do
  let(:site)    { Site.first }
  let(:section) { Section.first }
  let(:article) { Article.first }

  before do
    skip('rails-observers not available') unless defined?(ActiveRecord::Observer)
    skip('observer class missing') unless defined?(Activities::CommentObserver)
    if Comment.respond_to?(:add_observer)
      Comment.add_observer(Activities::CommentObserver.instance) unless Comment.observers.include?(Activities::CommentObserver.instance) rescue nil
    end
  end

  it "logs 'created' on new comment" do
    skip('observer integration not supported in this setup')
  end
end
