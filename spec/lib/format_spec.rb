require 'rails_helper'
require 'format'

RSpec.describe Format do
  describe 'EMAIL' do
    let(:regex) { described_class::EMAIL }

    it 'matches valid emails' do
      valid = [
        'user@example.com',
        'first.last@sub.domain.co',
        'a+b-c_d@foo-bar.baz',
        'UPPERlower123@test.io'
      ]
      valid.each do |email|
        expect(email).to match(regex)
      end
    end

    it 'allows blank strings (per legacy behavior)' do
      expect('').to match(regex)
      expect('   ').to match(regex)
    end

    it 'rejects invalid emails' do
      invalid = [
        'no-at-symbol',
        'user@',
        '@example.com',
        'user@example',
        'user@.com',
        'user@com.',
        'user@@example.com',
        'user example@example.com'
      ]
      invalid.each do |email|
        expect(email).not_to match(regex)
      end
    end
  end
end
