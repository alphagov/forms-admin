class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  rescue_from ActiveResource::ResourceNotFound, with: :render_not_found_error

  def render_not_found_error
    render "home/not_found", status: :not_found, formats: :html
  end
end
