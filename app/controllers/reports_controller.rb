class ReportsController < ApplicationController
  before_action :check_user_has_permission
  after_action :verify_authorized

  def index; end

  def features
    forms = Reports::FormDocumentsService.live_form_documents
    data = Reports::FeatureReportService.new(forms).report

    render template: "reports/features", locals: { tag: "live", data: }
  end

  def questions_with_answer_type
    answer_type = params.require(:answer_type)
    forms = Reports::FormDocumentsService.live_form_documents
    questions = Reports::FeatureReportService.new(forms).questions_with_answer_type(answer_type)

    render template: "reports/questions_with_answer_type", locals: { tag: "live", answer_type:, questions: }
  end

  def feature_report
    report = params[:report].underscore

    forms = Reports::FormDocumentsService.live_form_documents
    records = Reports::FeatureReportService.new(forms).report report

    if params[:format] == "csv"
      send_data Reports::CsvReportService.new(records).csv,
                type: "text/csv; charset=iso-8859-1",
                disposition: "attachment; filename=#{csv_filename("live_#{report}_report")}"
    else
      render template: "reports/feature_report", locals: { tag: "live", report:, records: }
    end
  end

  def users
    data = Reports::UsersReportService.new.user_data

    render locals: { data: }
  end

  def add_another_answer
    data = Report.find("add-another-answer-forms")

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
    forms = Reports::FormDocumentsService.live_form_documents

    send_data Reports::FormsCsvReportService.new(forms).csv,
              type: "text/csv; charset=iso-8859-1",
              disposition: "attachment; filename=#{csv_filename('live_forms_report')}"
  end

  def live_questions_csv
    answer_type = params[:answer_type]
    forms = Reports::FormDocumentsService.live_form_documents
    questions = if answer_type
                  Reports::FeatureReportService.new(forms).questions_with_answer_type(answer_type)
                else
                  Reports::FeatureReportService.new(forms).questions
                end

    send_data Reports::QuestionsCsvReportService.new(questions).csv,
              type: "text/csv; charset=iso-8859-1",
              disposition: "attachment; filename=#{questions_csv_filename(answer_type)}"
  end

private

  def check_user_has_permission
    authorize Report, :can_view_reports?
  end

  def questions_csv_filename(answer_type)
    base_name = "live_questions_report"
    base_name += "_#{answer_type}_answer_type" if answer_type.present?
    csv_filename(base_name)
  end

  def csv_filename(base_name)
    "#{base_name}-#{Time.zone.now}.csv"
  end
end
