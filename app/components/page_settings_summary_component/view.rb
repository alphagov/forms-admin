# frozen_string_literal: true

module PageSettingsSummaryComponent
  class View < ViewComponent::Base
    def initialize(page_object, change_answer_type_path: "", change_selections_settings_path: "", change_text_settings_path: "", change_date_settings_path: "", change_address_settings_path: "")
      super
      @page_object = page_object
      @change_answer_type_path = change_answer_type_path
      @change_selections_settings_path = change_selections_settings_path
      @change_text_settings_path = change_text_settings_path
      @change_date_settings_path = change_date_settings_path
      @change_address_settings_path = change_address_settings_path
    end

  private

    def address_input_type_to_string
      input_type = @page_object.answer_settings.input_type
      if input_type.uk_address == "true" && input_type.international_address == "true"
        "uk_and_international_addresses"
      elsif input_type.uk_address == "true"
        "uk_addresses"
      else
        "international_addresses"
      end
    end
  end
end
