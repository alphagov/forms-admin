class PageSettingsSummaryComponent::PageSettingsSummaryComponentPreview < ViewComponent::Preview
  def with_non_selection_answer_type
    draft_question = DraftQuestion.new(answer_type: "email")
    change_answer_type_path = "https://example.com/change_answer_type"
    render(PageSettingsSummaryComponent::View.new(draft_question, change_answer_type_path:))
  end

  def with_selection_answer_type
    draft_question = DraftQuestion.new(is_optional: "false",
                                       answer_type: "selection",
                                       answer_settings: { only_one_option: "true",
                                                          selection_options: [{ name: "Option 1" },
                                                                              { name: "Option 2" }] })
    change_answer_type_path = "https://example.com/change_answer_type"
    change_selections_settings_path = "https://example.com/change_selections_settings"
    render(PageSettingsSummaryComponent::View.new(draft_question, change_answer_type_path:, change_selections_settings_path:))
  end

  def with_text_answer_type
    draft_question = DraftQuestion.new(answer_type: "text", answer_settings: { input_type: "long_text" })
    change_answer_type_path = "https://example.com/change_answer_type"
    change_text_settings_path = "https://example.com/change_text_settings"
    render(PageSettingsSummaryComponent::View.new(draft_question, change_answer_type_path:, change_text_settings_path:))
  end

  def with_date_answer_type
    draft_question = DraftQuestion.new(answer_type: "date", answer_settings: { input_type: "date_of_birth" })
    change_answer_type_path = "https://example.com/change_answer_type"
    change_date_settings_path = "https://example.com/change_date_settings"
    render(PageSettingsSummaryComponent::View.new(draft_question, change_answer_type_path:, change_date_settings_path:))
  end

  def with_legacy_date_answer_type
    page = DraftQuestion.new(answer_type: "date")
    page.answer_settings = nil
    change_answer_type_path = "https://example.com/change_answer_type"
    change_date_settings_path = "https://example.com/change_date_settings"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path:, change_date_settings_path:))
  end

  def with_address_answer_type
    draft_question = DraftQuestion.new(answer_type: "address", answer_settings: { input_type: { uk_address: "true", international_address: "true" } })
    change_answer_type_path = "https://example.com/change_answer_type"
    change_address_settings_path = "https://example.com/change_address_settings"
    render(PageSettingsSummaryComponent::View.new(draft_question, change_answer_type_path:, change_address_settings_path:))
  end

  def with_name_answer_type
    draft_question = DraftQuestion.new(answer_type: "name", answer_settings: { input_type: "first_middle_and_last_name", title_needed: "true" })
    change_answer_type_path = "https://example.com/change_answer_type"
    change_name_settings_path = "https://example.com/change_name_settings"
    render(PageSettingsSummaryComponent::View.new(draft_question, change_answer_type_path:, change_name_settings_path:))
  end
end
