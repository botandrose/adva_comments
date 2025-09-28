require 'rails_helper'

RSpec.describe 'Comments routes', type: :routing do
  it 'routes GET /comments/:id to comments#show' do
    expect(get: '/comments/1').to route_to('comments#show', id: '1')
  end

  it 'routes POST /comments/preview to comments#preview' do
    expect(post: '/comments/preview').to route_to('comments#preview')
  end

  it 'routes admin comments index' do
    expect(get: '/admin/comments').to route_to('admin/comments#index')
  end

  it 'routes admin comments edit' do
    expect(get: '/admin/comments/2/edit').to route_to('admin/comments#edit', id: '2')
  end

  it 'routes admin comments update' do
    expect(put: '/admin/comments/2').to route_to('admin/comments#update', id: '2')
    expect(patch: '/admin/comments/2').to route_to('admin/comments#update', id: '2')
  end

  it 'routes admin comments destroy' do
    expect(delete: '/admin/comments/2').to route_to('admin/comments#destroy', id: '2')
  end
end

