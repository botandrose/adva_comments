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

  describe '#current_resource' do
    it 'returns the commentable when @comment is present' do
      controller.instance_variable_set(:@comment, comment)
      expect(controller.send(:current_resource)).to eq(comment.commentable)
    end

    it 'returns @content when @comment is nil and @content is present' do
      controller.instance_variable_set(:@comment, nil)
      content = double('content')
      controller.instance_variable_set(:@content, content)
      expect(controller.send(:current_resource)).to eq(content)
    end

    it 'falls back to @section when @comment and @content are nil' do
      controller.instance_variable_set(:@comment, nil)
      controller.instance_variable_set(:@content, nil)
      controller.instance_variable_set(:@section, section)
      expect(controller.send(:current_resource)).to eq(section)
    end

    it 'falls back to @site when others are nil' do
      controller.instance_variable_set(:@comment, nil)
      controller.instance_variable_set(:@content, nil)
      controller.instance_variable_set(:@section, nil)
      controller.instance_variable_set(:@site, site)
      expect(controller.send(:current_resource)).to eq(site)
    end
  end
end
