# frozen_string_literal: true

module PreviewLinkComponent
  class View < ApplicationComponent
    def initialize(pages, link_url, link_text = nil)
      super()
      @pages = pages
      @link_url = link_url
      @link_text = link_text
    end

    def render?
      @pages.any?
    end
  end
end
