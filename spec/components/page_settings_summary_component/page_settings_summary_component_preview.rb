class PageSettingsSummaryComponent::PageSettingsSummaryComponentPreview < ViewComponent::Preview
  def with_non_selection_answer_type
    page = FactoryBot.build(:page, :without_selection_answer_type, id: 1)
    change_answer_type_path = "https://example.com/change_answer_type"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path))
  end

  def with_selection_answer_type
    page = FactoryBot.build(:page, :with_selections_settings, id: 1)
    page.answer_settings = OpenStruct.new(page.answer_settings)
    change_answer_type_path = "https://example.com/change_answer_type"
    change_selections_settings_path = "https://example.com/change_selections_settings"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path, change_selections_settings_path))
  end
end
