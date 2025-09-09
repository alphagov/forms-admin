module ServiceNavigationComponent
  class View < ApplicationComponent
    attr_accessor :navigation_items

    def initialize(navigation_items: [])
      super
      @navigation_items = navigation_items.map(&:to_h)
    end

    def call
      govuk_service_navigation(current_path: request.fullpath,
                               navigation_items:,
                               classes: %w[app-service-navigation])
    end
  end
end
