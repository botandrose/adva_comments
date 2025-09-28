require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:section) { Section.first }
  let(:article) { Article.first }
  let(:comment) { article.comments.first || Comment.first }

  describe 'associations' do
    it { is_expected.to belong_to(:site) }
    it { is_expected.to belong_to(:section) }
    it { is_expected.to belong_to(:commentable) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:commentable) }
    it { is_expected.to validate_presence_of(:author_name) }
    it { is_expected.to validate_presence_of(:author_email) }
  end

  # Callbacks are covered by behavior specs below

  describe '#owner' do
    it 'returns the commentable' do
      expect(comment.owner).to eq(comment.commentable)
    end
  end

  describe '#filter' do
    it 'returns the comment_filter attribute of the commentable' do
      allow(comment.commentable).to receive(:comment_filter).and_return(:filter)
      expect(comment.filter).to eq(:filter)
    end
  end

  describe '#authorize_commenting' do
    it 'checks if the commentable accepts comments' do
      allow(comment.commentable).to receive(:accept_comments?).and_return(true)
      expect { comment.send(:authorize_commenting) }.not_to raise_error
    end

    it 'raises CommentNotAllowed if the commentable does not accept comments' do
      allow(comment.commentable).to receive(:accept_comments?).and_return(false)
      expect { comment.send(:authorize_commenting) }.to raise_error(Comment::CommentNotAllowed)
    end
  end

  describe '#set_owners' do
    it 'sets site and section from the commentable' do
      comment.site, comment.section = nil, nil
      comment.send(:set_owners)
      expect(comment.site).to eq(comment.commentable.site)
      expect(comment.section).to eq(comment.commentable.section)
    end
  end

  describe '#author_link' do
    it 'returns a link when author_homepage is present' do
      comment.author_homepage = 'http://somewhere.com'
      expect(comment.author_link).to eq(%(<a href="http://somewhere.com">#{comment.author_name}</a>))
    end

    it 'returns author name when author_homepage is not present' do
      comment.author_homepage = nil
      expect(comment.author_link).to eq(comment.author_name)
    end
  end
end
