class SiteFormBuilder < Adva::ExtensibleFormBuilder
  after(:site, :default_fields) do |f|
    render :partial => 'admin/sites/comments_settings', :locals => { :f => f }
  end
end

ActiveSupport::Reloader.to_prepare do
  Site.class_eval do
    has_many_comments
  end
end
