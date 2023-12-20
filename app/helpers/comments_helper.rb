module CommentsHelper
  def comments_feed_title(*owners)
    options = owners.extract_options!
    separator = options[:separator] || ' &raquo; '
    'Comments: ' + owners.compact.uniq.map(&:title).join(separator)
  end

  methods = %w(admin_comments_path admin_comment_path
               new_admin_comment_path edit_admin_comment_path)

  methods.each do |method|
    module_eval <<-CODE, __FILE__, __LINE__
      def #{method}(*args)
        options = args.extract_options!
        merge_admin_comments_query_params(options)
        super *(args << options).compact
      end
    CODE
  end

  def link_to_content_comments_count(content, options = {:total => true})
    total = content.comments_count
    approved = content.approved_comments_count
    return options[:alt] || "None" if approved == 0
    text = if total == approved or !options[:total]
      "#{approved.to_s.rjust(2, '0')}"
    else
      "#{approved.to_s.rjust(2, '0')} (#{total.to_s.rjust(2, '0')})"
    end
    link_to_content_comments(text, content)
  end

  def link_to_content_comments(*args)
    options = args.extract_options!
    text = args.shift if args.first.is_a?(String) || args.first.is_a?(Symbol)
    content, comment = *args
    return unless content.approved_comments_count > 0 || content.accept_comments?

    text = t(text) if text.is_a?(Symbol)
    text ||= pluralize(content.approved_comments_count, "comment")
    options.merge! :anchor => (comment ? dom_id(comment) : 'comments')
    link_to text, [content.section, content], options
  end

  def link_to_content_comment(*args)
    options = args.extract_options!
    args.insert(args.size - 1, args.last.commentable)
    link_to_content_comments(*args << options)
  end

  def link_to_remote_comment_preview
    link_to("Preview", preview_comments_path, :id => 'preview_comment', :style => "display:none;") +
      image_tag('adva_cms/indicator.gif', :alt => '', :id => 'comment_preview_spinner', :style => 'display:none;')
  end

  def comment_form_hidden_fields(commentable)
    hidden_field_tag('return_to', request.fullpath) + "\n" +
    hidden_field_tag('comment[commentable_type]', commentable.class.name, :id => 'comment_commentable_type') + "\n" +
    hidden_field_tag('comment[commentable_id]', commentable.id, :id => 'comment_commentable_id') + "\n"
  end

  private

    # TODO obviously doesn't work as expected on the SectionsController where the
    # section_id is in params[:id]
    def merge_admin_comments_query_params(options)
      options.merge! params.slice(:section_id, :content_id).reject{|key, value| value.blank? }.to_unsafe_hash
      options.symbolize_keys!
      options.delete(:section_id) if options[:content_id]
    end
end
