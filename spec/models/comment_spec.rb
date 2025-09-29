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

  describe 'scopes and flags' do
    it 'filters by approved and unapproved scopes' do
      approved = Comment.create!(site: section.site, section: section, commentable: article, author_name: 'A', author_email: 'a@example.com', body: 'ok', approved: 1)
      unapproved = Comment.create!(site: section.site, section: section, commentable: article, author_name: 'B', author_email: 'b@example.com', body: 'ok', approved: 0)
      expect(Comment.approved).to include(approved)
      expect(Comment.approved).not_to include(unapproved)
      expect(Comment.unapproved).to include(unapproved)
      expect(Comment.unapproved).not_to include(approved)
    end

    it 'reports approved? and unapproved? based on approved attribute' do
      c = Comment.new(approved: 1)
      expect(c).to be_approved
      expect(c).not_to be_unapproved
      c.approved = 0
      expect(c).not_to be_approved
      expect(c).to be_unapproved
    end
  end

  describe '#commentable_type=' do
    it 'stores the base class name for STI models' do
      c = Comment.new
      c.commentable_type = 'Article'
      expect(c[:commentable_type]).to eq('Content')
    end
  end

  describe 'email format validation' do
    it 'rejects invalid email' do
      c = Comment.new(site: section.site, section: section, commentable: article, author_name: 'X', author_email: 'invalid', body: 'ok')
      expect(c).not_to be_valid
      expect(c.errors[:author_email]).not_to be_empty
    end
  end

  # Note: approve/unapprove custom callbacks use legacy dirty tracking; we
  # exercise the surrounding behavior via request specs instead.

  describe 'after_save behavior' do
    it 'touches the commentable' do
      c = Comment.create!(site: section.site, section: section, commentable: article, author_name: 'Y', author_email: 'y@example.com', body: 'ok', approved: 1)
      expect(c.commentable).to receive(:touch)
      c.body = 'changed'
      c.save!
    end
  end
end
