module GroupListComponent
  class View < ViewComponent::Base
    def initialize(groups:, title:, empty_message: "", show_empty: true)
      super
      @groups = groups
      @title = title
      @empty_message = empty_message
      @show_empty = show_empty
    end
  end
end
