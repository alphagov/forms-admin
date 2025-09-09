# frozen_string_literal: true

module PageSettingsSummaryComponent
  class View < ApplicationComponent
    include Rails.application.routes.url_helpers
    include PagesHelper

    def initialize(draft_question:, errors: nil)
      super
      @draft_question = draft_question
      @errors = errors
    end

    def before_render
      super
      @change_answer_type_path = change_answer_type_path
      @change_address_settings_path = change_address_settings_path
      @change_date_settings_path = change_date_settings_path
      @change_name_settings_path = change_name_settings_path
      @change_text_settings_path = change_text_settings_path
      @change_selections_only_one_option_path = change_selections_only_one_option_path
      @change_selections_options_path = change_selections_options_path
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

      @draft_question.answer_settings
    end

    def selection_options
      answer_settings[:selection_options]
    end

    def change_answer_type_path
      if is_new_question?
        type_of_answer_new_path(form_id: @draft_question.form_id)
      else
        type_of_answer_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
      end
    end

    def change_address_settings_path
      return unless @draft_question.answer_type == "address"

      if is_new_question?
        address_settings_new_path(form_id: @draft_question.form_id)
      else
        address_settings_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
      end
    end

    def change_date_settings_path
      return unless @draft_question.answer_type == "date"

      if is_new_question?
        date_settings_new_path(form_id: @draft_question.form_id)
      else
        date_settings_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
      end
    end

    def change_name_settings_path
      return unless @draft_question.answer_type == "name"

      if is_new_question?
        name_settings_new_path(form_id: @draft_question.form_id)
      else
        name_settings_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
      end
    end

    def change_selections_only_one_option_path
      return unless @draft_question.answer_type == "selection"
      return selection_type_new_path(form_id: @draft_question.form_id) if is_new_question?

      selection_type_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
    end

    def change_selections_options_path
      return unless @draft_question.answer_type == "selection"

      return selection_options_new_path_for_draft_question(@draft_question) if is_new_question?

      selection_options_edit_path_for_draft_question(@draft_question)
    end

    def change_text_settings_path
      return unless @draft_question.answer_type == "text"

      return text_settings_new_path(form_id: @draft_question.form_id) if is_new_question?

      text_settings_edit_path(form_id: @draft_question.form_id, page_id: @draft_question.page_id)
    end

    def is_new_question?
      @draft_question.page_id.nil?
    end

    def show_selection_settings_summary
      @draft_question.answer_type == "selection"
    end

    def show_text_settings_summary
      @draft_question.answer_type == "text" && answer_settings.present? && answer_settings[:input_type]
    end

    def show_date_settings_summary
      @draft_question.answer_type == "date" && answer_settings.present? && answer_settings[:input_type]
    end

    def show_address_settings_summary
      @draft_question.answer_type == "address" && answer_settings.present? && answer_settings[:input_type]
    end

    def show_name_settings_summary
      @draft_question.answer_type == "name" && answer_settings.present? && answer_settings[:input_type]
    end
  end
end
