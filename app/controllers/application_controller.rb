class ApplicationController < ActionController::Base
  before_action :set_logging_attributes

  def set_logging_attributes
    CurrentLoggingAttributes.request_host = request.host
    CurrentLoggingAttributes.request_id = request.request_id
    CurrentLoggingAttributes.trace_id = request.env["HTTP_X_AMZN_TRACE_ID"].presence
    CurrentLoggingAttributes.form_id = params[:form_id] if params[:form_id].present?
  end
end
