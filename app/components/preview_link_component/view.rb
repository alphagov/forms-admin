# frozen_string_literal: true

module PreviewLinkComponent
  class View < ApplicationComponent
    def initialize(pages, link)
      super()
      @pages = pages
      @link = link
    end

    def render?
      @pages.any?
    end
  end
end
