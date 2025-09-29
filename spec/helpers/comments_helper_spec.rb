require 'rails_helper'

RSpec.describe CommentsHelper, type: :helper do
  include ContentHelper
  include ResourceHelper

  let(:site)    { Site.first }
  let(:section) { Section.first }
  let(:article) { Article.first }

  describe '#comments_feed_title' do
    it 'joins the titles of site, section and commentable' do
      title = helper.comments_feed_title(site, section, article)
      expect(title).to eq("Comments: #{site.title} &raquo; #{section.title} &raquo; #{article.title}")
    end
  end

  describe '#comment_form_hidden_fields' do
    it 'includes hidden fields for return_to and commentable' do
      allow(helper.request).to receive(:fullpath).and_return('/dummy/path')
      html = helper.comment_form_hidden_fields(article)
      expect(html).to include('name="return_to"')
      expect(html).to include('name="comment[commentable_type]"')
      expect(html).to include('name="comment[commentable_id]"')
    end
  end

  describe 'admin comments path param merging' do
    it 'adds :content_id when present and drops :section_id' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(site_id: 1, section_id: 2, content_id: 3))
      url = helper.admin_comments_path(site)
      expect(url).to include('content_id=3')
      expect(url).not_to include('section_id=')
    end

    it 'adds :section_id when :content_id is not present' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(site_id: 1, section_id: 2))
      url = helper.admin_comments_path(site)
      expect(url).to include('section_id=2')
    end
  end

  describe '#link_to_content_comments_count' do
    before do
      allow(helper).to receive(:link_to_content_comments) { |text, *_| "LINK:#{text}" }
    end

    it 'returns alt text when no approved comments' do
      content = double('content', comments_count: 0, approved_comments_count: 0)
      expect(helper.link_to_content_comments_count(content, alt: 'no comments')).to eq('no comments')
    end

    it 'formats approved count when total equals approved' do
      content = double('content', comments_count: 2, approved_comments_count: 2)
      expect(helper.link_to_content_comments_count(content)).to eq('LINK:02')
    end

    it 'formats approved and total when different and :total => true' do
      content = double('content', comments_count: 12, approved_comments_count: 3)
      expect(helper.link_to_content_comments_count(content)).to eq('LINK:03 (12)')
    end

    it 'formats approved only when :total => false' do
      content = double('content', comments_count: 12, approved_comments_count: 3)
      expect(helper.link_to_content_comments_count(content, total: false)).to eq('LINK:03')
    end
  end

  describe '#link_to_content_comments' do
    it 'returns nil if no approved comments and comments not accepted' do
      content = double('content', approved_comments_count: 0, accept_comments?: false)
      expect(helper.link_to_content_comments(content)).to be_nil
    end

    it 'links with pluralized text and comments anchor' do
      content = double('content', approved_comments_count: 2, accept_comments?: false, section: section)
      allow(helper).to receive(:link_to) { |text, *_| "LINK:#{text}" }
      expect(helper.link_to_content_comments(content)).to eq('LINK:2 comments')
    end

    it 'translates symbol link text' do
      content = double('content', approved_comments_count: 1, accept_comments?: false, section: section)
      allow(helper).to receive(:t).with(:foo).and_return('Translated')
      allow(helper).to receive(:link_to) { |text, *_| "LINK:#{text}" }
      expect(helper.link_to_content_comments(:foo, content)).to eq('LINK:Translated')
    end

    it 'links with dom_id anchor when comment provided' do
      content = double('content', approved_comments_count: 1, accept_comments?: false, section: section)
      comment = double('comment')
      allow(helper).to receive(:dom_id).with(comment).and_return('cmt_1')
      expect(helper).to receive(:link_to).with(anything, [section, content], hash_including(anchor: 'cmt_1'))
      helper.link_to_content_comments(content, comment)
    end
  end

  describe '#link_to_content_comment' do
    it 'delegates to link_to_content_comments with commentable inserted' do
      commentable = article
      comment = double('comment', commentable: commentable)
      expect(helper).to receive(:link_to_content_comments).with(commentable, comment, {})
      helper.link_to_content_comment(comment)
    end
  end

  describe '#link_to_remote_comment_preview' do
    it 'includes preview link and spinner image' do
      allow(helper).to receive(:image_tag).and_return('<img id="comment_preview_spinner">')
      allow(helper).to receive(:preview_comments_path).and_return('/comments/preview')
      html = helper.link_to_remote_comment_preview
      expect(html).to include('id="preview_comment"')
      expect(html).to include('comment_preview_spinner')
    end
  end
end
