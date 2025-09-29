require 'rails_helper'

RSpec.describe CommentMailer, type: :mailer do
  let(:site)    { Site.first }
  let(:section) { Section.first }
  let(:article) { Article.first }
  let(:comment) { Comment.first }

  before do
    allow_any_instance_of(Site).to receive(:email).and_return('noreply@example.com')
  end

  it 'builds a comment notification email' do
    mail = described_class.comment_notification(comment)
    expect(mail.to).to eq([site.email])
    expect(mail.from).to eq([site.email])
    expect(mail.subject).to include(site.name)
    expect(mail.content_type).to include('text/html')
  end
end
