class FeaturesReportService
  def features_data
    api_report = Report.find("features")

    features_rows = features_rows(api_report)
    answer_type_table_data = answer_type_table_data(api_report)

    {
      features_rows:,
      answer_type_table_data:,
    }
  end

private

  def features_rows(api_report)
    [
      { key: { text: I18n.t("reports.features.features.total_live_forms") }, value: { text: api_report.total_live_forms } },
      { key: { text: I18n.t("reports.features.features.live_forms_with_routes") }, value: { text: api_report.live_forms_with_routing } },
      { key: { text: I18n.t("reports.features.features.live_forms_with_payments") }, value: { text: api_report.live_forms_with_payment } },
    ]
  end

  def answer_type_table_data(api_report)
    {
      caption: I18n.t("reports.features.answer_types.heading"),
      head: [
        I18n.t("reports.features.answer_types.table_headings.answer_type"),
        { text: I18n.t("reports.features.answer_types.table_headings.number_of_forms"), numeric: true },
        { text: I18n.t("reports.features.answer_types.table_headings.number_of_pages"), numeric: true },
      ],
      rows: answer_type_rows(api_report),
      first_cell_is_header: true,
    }
  end

  def answer_type_rows(api_report)
    Page::ANSWER_TYPES.map(&:to_sym).map do |answer_type|
      [
        { text: I18n.t("helpers.label.page.answer_type_options.names.#{answer_type}") },
        { text: api_report.live_forms_with_answer_type.attributes[answer_type] || 0, numeric: true },
        { text: api_report.live_pages_with_answer_type.attributes[answer_type] || 0, numeric: true },
      ]
    end
  end
end
