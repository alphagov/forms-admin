class Forms::TranslationTablePresenter
  def two_column_classes
    ["govuk-!-margin-bottom-9", "app-form-field-table", "app-form-field-table--two-column"]
  end

  def two_column_headers
    { rows: [[
      { header: true, text: I18n.t("forms.welsh_translation.new.english_header") },
      { header: true, text: I18n.t("forms.welsh_translation.new.welsh_header") },
    ]] }
  end

  def three_column_classes
    ["govuk-!-margin-bottom-9", "app-form-field-table"]
  end

  def three_column_headers
    { rows: [[
      { header: true, text: nil },
      { header: true, text: I18n.t("forms.welsh_translation.new.english_header") },
      { header: true, text: I18n.t("forms.welsh_translation.new.welsh_header") },
    ]] }
  end
end
