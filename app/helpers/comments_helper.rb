module CommentsHelper
  def category_link(category)
    link_to category.name, category_path(category),
      class: "post-category",
      style: "color: #{category.color}; border-color: #{category.color};"
  end

  # Override this method to provide your own content formatting like Markdown
  def formatted_content(text)
    simple_format(text)
  end

  def forum_post_classes(comment)
    klasses = ["forum-post", "card", "mb-3"]
    klasses << "original-poster" if comment.user == @post.user
    klasses
  end

  def forum_user_badge(user)
    if user.respond_to?(:moderator) && user.moderator?
      content_tag :span, "Mod", class: "badge badge-default"
    end
  end
end
