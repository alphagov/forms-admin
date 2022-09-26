# frozen_string_literal: true

module PreviewLinkComponent
  class View < ViewComponent::Base
    def initialize(pages, link)
      super
      @pages = pages
      @link = link
    end

    def render?
      @pages.any?
    end
  end
end
