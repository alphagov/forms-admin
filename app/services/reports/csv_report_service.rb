class Reports::CsvReportService
  delegate :csv, to: :@csv_service

  def initialize(records)
    record_type = detect_record_type(records)
    @csv_service = csv_service_class(record_type).new(records)
  end

private

  class NilCsvService
    def initialize(_records); end

    def csv
      ""
    end
  end

  def csv_service_class(record_type)
    return NilCsvService if record_type.nil?

    "Reports::#{record_type.capitalize}CsvReportService".constantize
  end

  def detect_record_type(records)
    return if records.blank?

    type = records.first.fetch("type", "form")

    if type == "form"
      :forms
    elsif type == "question_page"
      :questions
    else
      raise "type of records '#{type}' is not one of 'forms', 'question_page'" unless type
    end
  end
end
