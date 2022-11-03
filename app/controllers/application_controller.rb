class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!
  before_action :set_user_instance_variable
  before_action :check_service_unavailable
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def check_service_unavailable
    if ENV["SERVICE_UNAVAILABLE"].present?
      render "errors/service_unavailable", status: :service_unavailable, formats: :html
    end
  end

  def set_user_instance_variable
    @current_user = current_user
  end

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    if current_user.present?
      payload[:user_id] = current_user.id
      payload[:user_email] = current_user.email
      payload[:user_organisation_slug] = current_user.organisation_slug
    end
    payload[:request_id] = request.request_id
  end
end
