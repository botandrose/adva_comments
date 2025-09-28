require 'spec_helper'

RSpec.describe 'Library entry points' do
  it 'loads top-level file and includes extension' do
    require 'has_counter'
    expect(ActiveRecord::Base.included_modules).to include(ActiveRecord::HasCounter)
  end
end
