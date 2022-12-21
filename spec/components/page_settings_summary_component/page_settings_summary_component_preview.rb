class PageSettingsSummaryComponent::PageSettingsSummaryComponentPreview < ViewComponent::Preview
  def with_non_selection_answer_type
    page = FactoryBot.build(:page, :with_simple_answer_type, id: 1)
    change_answer_type_path = "https://example.com/change_answer_type"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path:))
  end

  def with_selection_answer_type
    page = FactoryBot.build(:page, :with_selections_settings, id: 1)
    page.answer_settings = OpenStruct.new(page.answer_settings)
    change_answer_type_path = "https://example.com/change_answer_type"
    change_selections_settings_path = "https://example.com/change_selections_settings"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path:, change_selections_settings_path:))
  end

  def with_text_answer_type
    page = FactoryBot.build(:page, :with_text_settings, id: 1)
    page.answer_settings = OpenStruct.new(page.answer_settings)
    change_answer_type_path = "https://example.com/change_answer_type"
    change_text_settings_path = "https://example.com/change_text_settings"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path:, change_text_settings_path:))
  end

  def with_date_answer_type
    page = FactoryBot.build(:page, :with_date_settings, id: 1)
    page.answer_settings = OpenStruct.new(page.answer_settings)
    change_answer_type_path = "https://example.com/change_answer_type"
    change_date_settings_path = "https://example.com/change_date_settings"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path:, change_date_settings_path:))
  end

  def with_legacy_date_answer_type
    page = FactoryBot.build(:page, :with_date_settings, id: 1)
    page.answer_settings = nil
    change_answer_type_path = "https://example.com/change_answer_type"
    change_date_settings_path = "https://example.com/change_date_settings"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path:, change_date_settings_path:))
  end

  def with_date_answer_type
    page = FactoryBot.build(:page, :with_date_settings, id: 1)
    page.answer_settings = OpenStruct.new(page.answer_settings)
    change_answer_type_path = "https://example.com/change_answer_type"
    change_date_settings_path = "https://example.com/change_date_settings"
    render(PageSettingsSummaryComponent::View.new(page, change_answer_type_path, "", "", change_date_settings_path))
  end

  # TODO: Add preview for date and text inputs
end
