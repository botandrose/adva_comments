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
    if @comment.update comment_params
      trigger_events @comment
      flash[:notice] = t(:'adva.comments.flash.update.success')
      redirect_to params[:return_to] || admin_comments_url
    else
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

  def comment_params
    params.require(:comment).permit(:body, :approved)
  end
end
