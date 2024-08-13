class FeaturesReportService
  def features_data
    api_report = Report.find("features")

    features_rows = features_rows(api_report)

    {
      features_rows:,
      live_forms_with_answer_type: api_report.live_forms_with_answer_type,
      live_pages_with_answer_type: api_report.live_pages_with_answer_type,
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
end
