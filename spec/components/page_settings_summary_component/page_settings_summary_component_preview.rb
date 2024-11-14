class PageSettingsSummaryComponent::PageSettingsSummaryComponentPreview < ViewComponent::Preview
  def with_non_selection_answer_type
    draft_question = DraftQuestion.new(form_id: 1, answer_type: "email")
    render(PageSettingsSummaryComponent::View.new(draft_question:))
  end

  def with_selection_answer_type
    draft_question = DraftQuestion.new(form_id: 1,
                                       is_optional: "false",
                                       answer_type: "selection",
                                       answer_settings: { only_one_option: "true",
                                                          selection_options: [{ name: "Option 1" },
                                                                              { name: "Option 2" }] })
    render(PageSettingsSummaryComponent::View.new(draft_question:))
  end

  def with_selection_answer_type_and_10_or_more_options
    draft_question = DraftQuestion.new(form_id: 1,
                                       is_optional: "false",
                                       answer_type: "selection",
                                       answer_settings: { only_one_option: "true",
                                                          selection_options: [{ name: "Option 1" },
                                                                              { name: "Option 2" },
                                                                              { name: "Option 3" },
                                                                              { name: "Option 4" },
                                                                              { name: "Option 5" },
                                                                              { name: "Option 6" },
                                                                              { name: "Option 7" },
                                                                              { name: "Option 8" },
                                                                              { name: "Option 9" },
                                                                              { name: "Option 10" }] })
    render(PageSettingsSummaryComponent::View.new(draft_question:))
  end

  def with_text_answer_type
    draft_question = DraftQuestion.new(form_id: 1,
                                       answer_type: "text",
                                       answer_settings: { input_type: "long_text" })
    render(PageSettingsSummaryComponent::View.new(draft_question:))
  end

  def with_date_answer_type
    draft_question = DraftQuestion.new(form_id: 1,
                                       answer_type: "date",
                                       answer_settings: { input_type: "date_of_birth" })
    render(PageSettingsSummaryComponent::View.new(draft_question:))
  end

  def with_legacy_date_answer_type
    draft_question = DraftQuestion.new(form_id: 1,
                                       answer_type: "date")
    render(PageSettingsSummaryComponent::View.new(draft_question:))
  end

  def with_address_answer_type
    draft_question = DraftQuestion.new(form_id: 1,
                                       answer_type: "address",
                                       answer_settings: {
                                         input_type: {
                                           uk_address: "true",
                                           international_address: "true",
                                         },
                                       })
    render(PageSettingsSummaryComponent::View.new(draft_question:))
  end

  def with_name_answer_type
    draft_question = DraftQuestion.new(form_id: 1,
                                       answer_type: "name",
                                       answer_settings: {
                                         input_type: "first_middle_and_last_name",
                                         title_needed: "true",
                                       })
    render(PageSettingsSummaryComponent::View.new(draft_question:))
  end
end
