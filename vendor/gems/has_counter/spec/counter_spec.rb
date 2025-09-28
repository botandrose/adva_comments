require 'spec_helper'

RSpec.describe Counter do
  before do
    Counter.delete_all
    @owner = CounterSpec::Content.create!(title: 'own')
    # touch lazy creation
    @counter = @owner.comments_counter
  end

  it 'increments by a value' do
    expect { @counter.increment_by!(3) }.to change { @counter.reload.count }.from(0).to(3)
  end

  it 'decrements by a value' do
    @counter.update!(count: 5)
    expect { @counter.decrement_by!(2) }.to change { @counter.reload.count }.from(5).to(3)
  end
end

