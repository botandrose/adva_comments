require 'spec_helper'

module CounterSpec
  class Content < ActiveRecord::Base
    # Define an extra counter with explicit after_create option to exercise merge path
    has_counter :proc_comments,
                class_name: 'CounterSpec::Comment',
                after_create: :increment!
  end
end

RSpec.describe 'has_counter callbacks option' do
  before do
    Counter.delete_all
    CounterSpec::Content.delete_all
    CounterSpec::Comment.delete_all
    @content = CounterSpec::Content.create!(title: 'callbacks content')
  end

  it 'applies explicit callbacks override' do
    @content.proc_comments_count.should == 0
    @content.comments.create!(text: 'first')
    @content.proc_comments_count.should == 1
  end
end
