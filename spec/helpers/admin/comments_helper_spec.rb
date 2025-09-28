require 'rails_helper'

RSpec.describe Admin::CommentsHelper, type: :helper do
  include Admin::CommentsHelper

  describe '#comment_expiration_options' do
    it 'returns six [label, value] pairs with expected values' do
      opts = helper.comment_expiration_options
      expect(opts.size).to eq(6)
      expect(opts.map(&:last)).to eq([-1, 0, 1, 7, 30, 90])
      expect(opts.map(&:first)).to all(be_a(String))
    end
  end

  describe '#comments_state_options' do
    it 'returns approved/unapproved state pairs' do
      opts = helper.comments_state_options
      expect(opts.map(&:last)).to eq(%w[approved unapproved])
      expect(opts.map(&:first)).to all(be_a(String))
    end
  end
end

