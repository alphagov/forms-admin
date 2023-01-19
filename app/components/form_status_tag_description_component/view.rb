module FormStatusTagDescriptionComponent
  class View < ViewComponent::Base
    attr_accessor :status

    def initialize(status: "DRAFT")
      super
      @status = status.upcase
    end
  end
end
