# frozen_string_literal: true

module PreviewLinkComponent
  class View < ViewComponent::Base
    def initialize(pages, link)
      super
      @pages = pages
      @link = link
    end
  end
end
