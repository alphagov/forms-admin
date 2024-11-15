class ReportsController < ApplicationController
  before_action :check_user_has_permission
  after_action :verify_authorized

  def index; end

  def features
    data = Report.find("features")

    render template: "reports/features", locals: { data: }
  end

  def users
    data = UsersReportService.new.user_data

    render locals: { data: }
  end

  def add_another_answer
    data = Report.find("features")

    render template: "reports/add_another_answer", locals: { data: }
  end

  def last_signed_in_at
  def last_signed_in_at; end

private

  def check_user_has_permission
    authorize Report, :can_view_reports?
  end
end
