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
end
