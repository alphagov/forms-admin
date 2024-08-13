class FeaturesReportService
  def features_data
    Report.find("features")
  end
end
