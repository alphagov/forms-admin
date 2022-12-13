# frozen_string_literal: true

module PageSettingsSummaryComponent
  class View < ViewComponent::Base
    def initialize(page_object, change_answer_type_path = "", change_selections_settings_path = "")
      super
      @page_object = page_object
      @change_answer_type_path = change_answer_type_path
      @change_selections_settings_path = change_selections_settings_path
    end
  end
end
