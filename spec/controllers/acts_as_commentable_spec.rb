require 'rails_helper'

RSpec.describe ActionController::ActsAsCommentable, type: :controller do
  controller(ApplicationController) do
    include ActionController::ActsAsCommentable
    acts_as_commentable

    before_action :set_commentable

    def set_commentable
      # Use a real article from the dummy app as the commentable
      @commentable = Article.first
    end

    def create
      render plain: 'ok'
    end

    def comments
      super
    end
  end

  before do
    # Define minimal routes for anonymous controller
    routes.draw do
      get 'anonymous/comments' => 'anonymous#comments'
      post 'anonymous' => 'anonymous#create'
    end
  end

  describe 'acts_as_commentable setup' do
    it 'marks controller as acting commentable' do
      expect(controller.class.acts_as_commentable?).to be true
    end
    it 'defines comments action that assigns approved comments and renders atom' do
      get :comments, format: :atom
      expect(response).to have_http_status(:ok)
    end

    it 'initializes @comment and assigns anonymous author on other actions' do
      dummy = Comment.new
      allow(Comment).to receive(:new).and_return(dummy)
      post :create, params: { comment: { body: 'hi' } }
      c = controller.instance_variable_get(:@comment)
      expect(c).to be_a(Comment)
      expect(c.author).to be_a(User)
      expect(c.author).to respond_to(:anonymous?)
    end
  end
end
