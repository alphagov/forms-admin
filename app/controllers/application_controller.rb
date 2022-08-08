class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!
  before_action :check_service_unavailable
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  rescue_from ActiveResource::ResourceNotFound, with: :render_not_found_error

  def check_service_unavailable
    if ENV["SERVICE_UNAVAILABLE"].present?
      render "errors/service_unavailable", status: :service_unavailable, formats: :html
    end
  end
end
