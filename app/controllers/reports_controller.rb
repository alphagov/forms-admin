class ReportsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize Report, :can_view_reports?
  end

  def features
    authorize Report, :can_view_reports?

    data = FeaturesReportService.new.features_data

    render locals: { data: }
  end

  def users
    authorize Report, :can_view_reports?

    data = UsersReportService.new.user_data

    render locals: { data: }
  end
end
