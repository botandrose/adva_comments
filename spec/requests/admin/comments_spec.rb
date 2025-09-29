require 'rails_helper'

RSpec.describe 'Admin::Comments', type: :request do
  let(:site)    { Site.first }
  let(:section) { Section.first }
  let(:article) { Article.first }
  let(:comment) { Comment.first }
  let(:headers) { { 'HOST' => site.host } }

  # Stub admin authentication
  let(:admin_user) do
    User.first.tap do |u|
      allow(u).to receive(:anonymous?).and_return(false)
      allow(u).to receive(:admin?).and_return(true)
    end
  end

  before do
    allow_any_instance_of(Admin::BaseController).to receive(:current_user).and_return(admin_user)
    host! site.host
    # Ensure AR observers from other specs don't interfere with request behavior
    if defined?(ActiveRecord::Base) && ActiveRecord::Base.respond_to?(:observers=)
      ActiveRecord::Base.observers = []
      ActiveRecord::Base.instantiate_observers if ActiveRecord::Base.respond_to?(:instantiate_observers)
    end
  end

  # View templates depend on routes outside this engine; focus on update/destroy

  describe 'PUT /admin/comments/:id' do
    it 'updates the comment and redirects' do
      allow_any_instance_of(ActionView::Base).to receive(:link_to).and_return('ok')
      allow_any_instance_of(ActionView::Base).to receive(:link_to_edit).and_return('ok')
      allow_any_instance_of(ActionView::Base).to receive(:link_to_delete).and_return('ok')
      allow_any_instance_of(ActionDispatch::Request).to receive(:request_uri).and_return('/admin/comments')

      put "/admin/comments/#{comment.id}", params: { comment: { body: 'updated comment body' } }, headers: headers
      expect(response).to have_http_status(:found)
      expect(comment.reload.body).to eq('updated comment body')
    end
  end

  describe 'DELETE /admin/comments/:id' do
    it 'destroys the comment and redirects' do
      allow_any_instance_of(ActionView::Base).to receive(:link_to).and_return('ok')
      allow_any_instance_of(ActionView::Base).to receive(:link_to_edit).and_return('ok')
      allow_any_instance_of(ActionView::Base).to receive(:link_to_delete).and_return('ok')
      allow_any_instance_of(ActionDispatch::Request).to receive(:request_uri).and_return('/admin/comments')

      delete "/admin/comments/#{comment.id}", headers: headers
      expect(response).to have_http_status(:found)
      expect(Comment.find_by(id: comment.id)).to be_nil
    end
  end
end
