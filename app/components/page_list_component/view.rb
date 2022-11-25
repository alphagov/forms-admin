module PageListComponent
  class View < ViewComponent::Base
    delegate :question_text_with_optional_suffix, to: :helpers

    def initialize(form_id:, pages: [])
      super
      @pages = pages
      @form_id = form_id
    end
  end
end
