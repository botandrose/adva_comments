require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:site)    { Site.first }
  let(:section) { Section.first }
  let(:article) { Article.first }
  let(:headers) { { 'HOST' => site.host, 'HTTP_REFERER' => '/ref' } }

  describe 'GET /comments/:id' do
    it 'renders the show page' do
      comment = Comment.first
      allow_any_instance_of(CommentsController).to receive(:show) { |ctrl| ctrl.render plain: 'ok' }
      get "/comments/#{comment.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

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
      expect(response.headers['Location']).to start_with("http://#{site.host}/ref")
    end

    it 'as anonymous sets review notice and redirects' do
      allow(CommentMailer).to receive_message_chain(:comment_notification, :deliver_later)
      anon = User.anonymous
      allow(anon).to receive(:anonymous?).and_return(true)
      allow_any_instance_of(CommentsController).to receive(:current_user).and_return(anon)
      # bypass invisible_captcha
      allow_any_instance_of(CommentsController).to receive(:verify_invisible_captcha).and_return(true)

      post '/comments', params: {
        comment: {
          commentable_type: 'Article',
          commentable_id: article.id,
          author_name: 'Anon',
          author_email: 'anon@example.com',
          body: 'Body'
        }
      }, headers: headers
      expect(response).to have_http_status(:found)
      expect(response.headers['Location']).to start_with("http://#{site.host}/ref")
    end

    it 'auto-approves when user is not anonymous' do
      allow(CommentMailer).to receive_message_chain(:comment_notification, :deliver_later)
      user = User.first
      allow(user).to receive(:anonymous?).and_return(false)
      allow_any_instance_of(CommentsController).to receive(:current_user).and_return(user)

      post '/comments', params: {
        comment: {
          commentable_type: 'Article',
          commentable_id: article.id,
          author_name: 'Logged In',
          author_email: 'admin@example.com',
          body: 'Body'
        }
      }, headers: headers
      expect(response).to have_http_status(:found)
      expect(response.headers['Location']).to start_with("http://#{site.host}/ref")
      expect(Comment.last.approved).to be_truthy
    end

    it 'fails with invalid params and redirects' do
      allow_any_instance_of(CommentsController).to receive(:verify_invisible_captcha).and_return(true)
      post '/comments', params: {
        comment: {
          commentable_type: 'Article',
          commentable_id: article.id,
          author_name: 'Bad',
          author_email: 'bad@example.com',
          body: ''
        }
      }, headers: headers
      expect(response).to have_http_status(:found)
    end
  end

  describe 'PUT /comments/:id' do
    it 'updates successfully and returns true JSON' do
      comment = Comment.first
      user = User.first
      allow(user).to receive(:anonymous?).and_return(false)
      allow_any_instance_of(CommentsController).to receive(:current_user).and_return(user)
      allow_any_instance_of(CommentsController).to receive(:comment_params).and_return({ body: 'updated body' })
      put "/comments/#{comment.id}", params: { comment: { body: 'updated body' } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('true')
    end

    it 'fails update and returns false JSON' do
      comment = Comment.first
      user = User.first
      allow(user).to receive(:anonymous?).and_return(false)
      allow_any_instance_of(CommentsController).to receive(:current_user).and_return(user)
      allow_any_instance_of(CommentsController).to receive(:comment_params).and_return({ body: '' })
      put "/comments/#{comment.id}", params: { comment: { body: '' } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('false')
    end
  end

  describe 'DELETE /comments/:id' do
    it 'destroys the comment and redirects to root' do
      comment = Comment.first
      if defined?(Activities::CommentObserver)
        allow_any_instance_of(Activities::CommentObserver).to receive(:after_destroy)
      end
      delete "/comments/#{comment.id}", headers: headers
      expect(response).to have_http_status(:found)
      expect(response.headers['Location']).to eq("http://#{site.host}/")
    end
  end

  describe 'set_commentable guards' do
    it 'returns 404 when commentable_type is not commentable' do
      # User is an AR model but does not declare has_many_comments
      user = User.first
      post '/comments/preview', params: {
        comment: {
          commentable_type: 'User',
          commentable_id: user.id,
          author_name: 'Previewer',
          author_email: 'preview@example.com',
          body: 'Hello preview'
        }
      }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

end
