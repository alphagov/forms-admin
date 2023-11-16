# frozen_string_literal: true

module PageSettingsSummaryComponent
  class View < ViewComponent::Base
    include Rails.application.routes.url_helpers
    def initialize(draft_question, change_date_settings_path: "", change_address_settings_path: "", change_name_settings_path: "")
      super
      @draft_question = draft_question
      @change_date_settings_path = change_date_settings_path
      @change_address_settings_path = change_address_settings_path
      @change_name_settings_path = change_name_settings_path
    end

    def before_render
      super
      @change_answer_type_path = change_answer_type_path
      @change_selections_settings_path = change_selections_settings_path
      @change_text_settings_path = change_text_settings_path
    end

  private

    def address_input_type_to_string
      input_type = answer_settings[:input_type]
      if input_type[:uk_address] == "true" && input_type[:international_address] == "true"
        "uk_and_international_addresses"
      elsif input_type[:uk_address] == "true"
        "uk_addresses"
      else
        "international_addresses"
      end
    end

    def answer_settings
      return [] if @draft_question.answer_settings.nil?

      @draft_question.answer_settings.with_indifferent_access
    end

    def show_selection_options
      answer_settings[:selection_options].map { |option| option[:name] }.join(", ")
    end

    def change_answer_type_path
      if is_new_question?
        type_of_answer_new_path(form_id: @draft_question.form_id)
      else
        type_of_answer_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
      end
    end

    def change_selections_settings_path
      return unless @draft_question.answer_type == "selection"

      if is_new_question?
        selections_settings_new_path(form_id: @draft_question.form_id)
      else
        selections_settings_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
      end
    end

    def change_text_settings_path
      return unless @draft_question.answer_type == "text"

      if is_new_question?
        text_settings_new_path(form_id: @draft_question.form_id)
      else
        text_settings_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
      end
    end

    def is_new_question?
      @draft_question.page_id.nil?
    end
  end
end
