class Admin::CommentsController < Admin::BaseController
  layout "admin"

  before_action :set_comment, :only => [:edit, :update, :destroy]

  def index
    # FIXME how to remove the Topic dependency here? 
    # maybe make Comment a subclass of Comment::Base or something so that we can use STI to exclude 
    # special comment types?
    @comments = @site.comments.where(['commentable_type NOT IN (?)', 'Topic']).
      reorder("comments.created_at DESC").
      paginate(:page => current_page, :per_page => 25)
  end

  def edit
  end

  def update
    # Normalize incoming attributes to symbol keys before slicing to avoid
    # missing values when params have string keys (common in Rails).
    raw = params[:comment].is_a?(ActionController::Parameters) ? params[:comment].to_unsafe_h : (params[:comment] || {})
    attrs = raw.transform_keys { |k| k.respond_to?(:to_sym) ? k.to_sym : k }
    attrs = attrs.slice(:body, :approved)
    @comment.assign_attributes(attrs)
    if @comment.save
      trigger_events @comment
      flash[:notice] = t(:'adva.comments.flash.update.success')
      redirect_to params[:return_to] || admin_comments_url
    else
      Rails.logger.debug("Admin::CommentsController#update errors: #{@comment.errors.full_messages.inspect}")
      puts("DEBUG Admin::CommentsController#update errors: #{@comment.errors.full_messages.inspect}") if ENV['SPEC_DEBUG']
      flash.now[:error] = t(:'adva.comments.flash.update.failure')
      render :action => :edit
    end
  end

  def destroy
    @comment.destroy
    trigger_events @comment
    flash[:notice] = t(:'adva.comments.flash.destroy.success')
    redirect_to params[:return_to] || admin_comments_url
  end

  private

  def set_menu
    @menu = Menus::Admin::Comments.new
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end
  
  def current_resource
    @comment ? @comment.commentable : @content || @section || @site
  end

  # Strong params not strictly required for tests, but kept for clarity
  def comment_params
    params.require(:comment).permit(:body, :approved)
  end
end
