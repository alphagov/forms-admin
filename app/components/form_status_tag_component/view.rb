module FormStatusTagComponent
  class View < ViewComponent::Base
    def initialize(status: :draft)
      super
      @status = status.to_sym
    end

    def status_colour
      {
        draft: "purple",
        live: "blue",
      }[@status]
    end

    def status_text
      # i18n-tasks-use t('form_statuses.draft')
      # i18n-tasks-use t('form_statuses.live')
      I18n.t("form_statuses.#{@status}")
    end
  end
end
