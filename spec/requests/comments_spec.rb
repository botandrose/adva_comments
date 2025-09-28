require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:site)    { Site.first }
  let(:section) { Section.first }
  let(:article) { Article.first }
  let(:headers) { { 'HOST' => site.host, 'HTTP_REFERER' => '/ref' } }

  # NOTE: GET /comments/:id view relies on adva content routes (e.g., article_path).
  # Request-level behavior is covered via routing specs.

  describe 'POST /comments/preview' do
    it 'renders a comment preview' do
      allow_any_instance_of(Comment).to receive(:process_filters)
      post '/comments/preview', params: {
        comment: {
          commentable_type: 'Article',
          commentable_id: article.id,
          author_name: 'Previewer',
          author_email: 'preview@example.com',
          body: 'Hello preview'
        }
      }, headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /comments' do
    it 'creates a comment and redirects back' do
      allow(CommentMailer).to receive_message_chain(:comment_notification, :deliver_later)

      post '/comments', params: {
        comment: {
          commentable_type: 'Article',
          commentable_id: article.id,
          author_name: 'New Author',
          author_email: 'new@example.com',
          body: 'New comment body'
        }
      }, headers: headers

      expect(response).to have_http_status(:found)
      # Rack test omits URL fragments in Location; just assert base path
      expect(response.headers['Location']).to eq("http://#{site.host}/ref")
    end
  end

  # Skipping update/destroy here due to invisible_captcha filter; covered via admin flows
end
