ActiveSupport::Reloader.to_prepare do
  Article.class_eval do
    def accept_comments?
      published? && (comment_age > -1) && (comment_age == 0 || comments_expired_at > Time.zone.now)
    end
  end
end

class ArticleFormBuilder < Adva::ExtensibleFormBuilder
  after(:article, :filter) do |f|
    render :partial => 'admin/articles/comments_settings', :locals => { :f => f }
  end
end
