class ErrorsController < ApplicationController
  skip_before_action :authenticate_and_check_access, except: :forbidden
  skip_before_action :check_service_unavailable, only: :maintenance

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def forbidden
    render status: :forbidden
  end

  def maintenance
    render "errors/service_unavailable", status: :service_unavailable, formats: :html
  end
end
