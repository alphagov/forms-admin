class ReportsController < ApplicationController
  before_action :check_user_has_permission
  after_action :verify_authorized

  def index; end

  def features
    data = Reports::FeatureReportService.report

    render template: "reports/features", locals: { data: }
  end

  def users
    data = Reports::UsersReportService.new.user_data

    render locals: { data: }
  end

  def add_another_answer
    data = Report.find("features")

    render template: "reports/add_another_answer", locals: { data: }
  end

  def last_signed_in_at; end

  def selection_questions_summary
    data = Report.find("selection-questions-summary")

    render template: "reports/selection_questions/summary", locals: { data: }
  end

  def selection_questions_with_autocomplete
    data = Report.find("selection-questions-with-autocomplete")

    render template: "reports/selection_questions/autocomplete", locals: { data: }
  end

  def selection_questions_with_radios
    data = Report.find("selection-questions-with-radios")

    render template: "reports/selection_questions/radios", locals: { data: }
  end

  def selection_questions_with_checkboxes
    data = Report.find("selection-questions-with-checkboxes")

    render template: "reports/selection_questions/checkboxes", locals: { data: }
  end

  def csv_downloads; end

  def live_forms_csv
    send_data Reports::CsvReportsService.new.live_forms_csv,
              type: "text/csv; charset=iso-8859-1",
              disposition: "attachment; filename=#{csv_filename('live_forms_report')}"
  end

  def live_questions_csv
    send_data Reports::CsvReportsService.new.live_questions_csv,
              type: "text/csv; charset=iso-8859-1",
              disposition: "attachment; filename=#{csv_filename('live_questions_report')}"
  end

private

  def check_user_has_permission
    authorize Report, :can_view_reports?
  end

  def csv_filename(base_name)
    "#{base_name}-#{Time.zone.now}.csv"
  end
end
