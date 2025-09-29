require 'validates_email_format_of'

class Comment < ActiveRecord::Base
  class CommentNotAllowed < StandardError; end

  def self.approved
    where :approved => true
  end

  def self.unapproved
    where :approved => false
  end

  after_save do
    commentable.touch
  end


  belongs_to :site
  belongs_to :section
  belongs_to :commentable, :polymorphic => true
  # make sure we're storing the base clase for STI
  def commentable_type=(sType)
    super(sType.to_s.classify.constantize.base_class.to_s)
  end
  has_many :activities, :as => :object

  composed_of :author, :class_name => "User", :mapping => [ %w(author_name name), %w(author_email email) ]

  validates_presence_of :body, :commentable, :author_name, :author_email
  validates_email_format_of :author_email

  before_validation :set_owners
  before_create :authorize_commenting

  def owner
    commentable
  end

  def filter
    commentable.comment_filter
  end

  def author_link
    name = author_name.presence || (respond_to?(:author) && author.respond_to?(:name) ? author.name : nil)
    return name unless author_homepage.present?
    %(<a href="#{author_homepage}">#{name}</a>).html_safe
  end

  def unapproved?
    !approved?
  end

  define_model_callbacks :approve, :unapprove

  protected

  def authorize_commenting
    if commentable && !commentable.accept_comments?
      raise CommentNotAllowed, I18n.t(:'adva.comments.messages.not_allowed')
    end
  end

  def set_owners
    if commentable # TODO in what cases would commentable be nil here?
      self.site = commentable.site
      self.section = commentable.section
    end
  end
end
