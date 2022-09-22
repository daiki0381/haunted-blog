# frozen_string_literal: true

module BlogsHelper
  def format_content(blog)
    content_tag(h(blog.content).gsub("\n", '<br>'))
  end
end
