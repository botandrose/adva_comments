require 'rails_helper'

RSpec.describe Admin::CommentsController, type: :controller do
  let(:site)    { Site.first }
  let(:section) { Section.first }
  let(:article) { Article.first }
  let!(:comment) { Comment.first }

  let(:admin_user) do
    User.first.tap do |u|
      allow(u).to receive(:anonymous?).and_return(false)
      allow(u).to receive(:admin?).and_return(true)
    end
  end

  before do
    @request.host = site.host
    allow(controller).to receive(:current_user).and_return(admin_user)
  end

  describe 'PUT update' do
    it 'updates the comment and redirects' do
      put :update, params: { id: comment.id, comment: { body: 'updated comment body' } }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(admin_comments_url)
      expect(comment.reload.body).to eq('updated comment body')
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the comment and redirects' do
      delete :destroy, params: { id: comment.id }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(admin_comments_url)
      expect(Comment.find_by(id: comment.id)).to be_nil
    end
  end

  describe 'GET index' do
    it 'renders successfully' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET edit' do
    it 'renders edit' do
      get :edit, params: { id: comment.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT update failure' do
    it 'renders edit and does not change the comment' do
      original = comment.body
      put :update, params: { id: comment.id, comment: { body: '' } }
      expect(response).to have_http_status(:ok)
      expect(comment.reload.body).to eq(original)
    end
  end
end
