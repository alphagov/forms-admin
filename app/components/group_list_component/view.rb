module GroupListComponent
  class View < ViewComponent::Base
    def initialize(groups:, title:, empty_message:)
      super
      @groups = groups
      @title = title
      @empty_message = empty_message
    end
  end
end
