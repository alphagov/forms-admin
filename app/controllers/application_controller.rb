class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
end
