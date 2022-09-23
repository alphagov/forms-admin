module FormStatusTagComponent
  class View < ViewComponent::Base
    attr_accessor :status

    def initialize(status: "DRAFT")
      super
      @status = status.upcase
    end

    def status_colour
      {
        draft: "purple",
        live: "blue",
      }[status.downcase.to_sym]
    end
  end
end
