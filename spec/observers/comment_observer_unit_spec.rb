require 'rails_helper'

RSpec.describe Activities::CommentObserver do
  let(:observer) { described_class.instance }

  describe '#collect_activity_attributes' do
    it 'builds attributes from the record clone and commentable' do
      commentable = double('commentable', has_attribute?: false, title: 'A Title')
      record = double('record',
        clone_attributes: {
          'commentable_id' => 42,
          'body' => 'Body',
          'author_name' => 'Alice',
          'author_email' => 'alice@example.com',
          'author_url' => 'http://example.com'
        },
        commentable: commentable,
        commentable_type: 'Article'
      )

      attrs = observer.send(:collect_activity_attributes, record)
      expect(attrs['commentable_id']).to eq(42)
      expect(attrs['body']).to eq('Body')
      expect(attrs['author_name']).to eq('Alice')
      expect(attrs['author_email']).to eq('alice@example.com')
      expect(attrs['commentable_type']).to eq('Article')
      expect(attrs['commentable_title']).to eq('A Title')
    end
  end

  describe '#collect_actions' do
    it "includes 'created' when record is new" do
      record = double('record', new_record?: true, frozen?: false, body_changed?: false, approved_changed?: false, approved?: false, unapproved?: true)
      actions = observer.send(:collect_actions, record)
      expect(actions).to include('created')
    end

    it "includes 'deleted' when record is frozen" do
      record = double('record', new_record?: false, frozen?: true, body_changed?: false, approved_changed?: false, approved?: false, unapproved?: true)
      actions = observer.send(:collect_actions, record)
      expect(actions).to include('deleted')
    end
  end

  describe '#initialize_activity' do
    it 'sets site and section and caches author fields' do
      site = Site.first
      section = Section.first
      commentable = double('commentable', site: site, section: section, has_attribute?: false, title: 'A Title')
      record = double('record',
        commentable: commentable,
        respond_to?: true,
        author_name: 'Bob',
        author_email: 'bob@example.com',
        author_homepage: nil,
        clone_attributes: { 'commentable_id' => 1, 'body' => 'B', 'author_name' => 'Bob', 'author_email' => 'bob@example.com', 'author_url' => nil },
        # for collect_actions conditions
        new_record?: false,
        frozen?: false,
        body_changed?: false,
        approved_changed?: false,
        approved?: false,
        unapproved?: true,
        commentable_type: 'Article'
      )
      activity = observer.send(:initialize_activity, record)
      expect(activity.site).to eq(site)
      expect(activity.section).to eq(section)
      expect(activity.author_name).to eq('Bob')
      expect(activity.author_email).to eq('bob@example.com')
    end
  end
end
