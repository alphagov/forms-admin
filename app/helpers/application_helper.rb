# frozen_string_literal: true

# Rubocop ate my lunch
module ApplicationHelper
  def page_title(separator = " – ")
    [content_for(:title), "GOV.UK Forms"].compact.join(separator)
  end

  def set_page_title(title)
    content_for(:title) { title }
  end
end
