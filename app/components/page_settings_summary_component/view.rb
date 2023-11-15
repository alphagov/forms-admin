# frozen_string_literal: true

module PageSettingsSummaryComponent
  class View < ViewComponent::Base
    def initialize(draft_question, change_answer_type_path: "", change_selections_settings_path: "", change_text_settings_path: "", change_date_settings_path: "", change_address_settings_path: "", change_name_settings_path: "")
      super
      @draft_question = draft_question
      @change_answer_type_path = change_answer_type_path
      @change_selections_settings_path = change_selections_settings_path
      @change_text_settings_path = change_text_settings_path
      @change_date_settings_path = change_date_settings_path
      @change_address_settings_path = change_address_settings_path
      @change_name_settings_path = change_name_settings_path
    end

  private

    def address_input_type_to_string
      input_type = settings[:input_type]
      if input_type[:uk_address] == "true" && input_type[:international_address] == "true"
        "uk_and_international_addresses"
      elsif input_type[:uk_address] == "true"
        "uk_addresses"
      else
        "international_addresses"
      end
    end

    def settings
      return [] if @draft_question.answer_settings.nil?

      @draft_question.answer_settings.with_indifferent_access
    end

    def show_selection_options
      settings[:selection_options].map { |option| option[:name] }.join(", ")
    end
  end
end
