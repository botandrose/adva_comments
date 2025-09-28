require 'rails_helper'

RSpec.describe Content, type: :model do
  describe 'comments associations' do
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:approved_comments) }
    it { is_expected.to have_many(:unapproved_comments) }
  end
end

