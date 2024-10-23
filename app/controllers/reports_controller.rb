class ReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize Report, :can_view_reports?
  end

  def features
    authorize Report, :can_view_reports?

    data = Report.find("features")

    render template: "reports/features", locals: { data: }
  end

  def users
    authorize Report, :can_view_reports?

    data = UsersReportService.new.user_data

    render locals: { data: }
  end

  def add_another_answer
    authorize Report, :can_view_reports?

    data = Report.find("features")

    render template: "reports/add_another_answer", locals: { data: }
  end
end
