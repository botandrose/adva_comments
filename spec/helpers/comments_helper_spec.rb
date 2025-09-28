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
end
