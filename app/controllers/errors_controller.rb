class ErrorsController < ApplicationController
  skip_before_action :authenticate_and_check_access, except: :forbidden
  skip_before_action :check_maintenance_mode_is_enabled, only: :maintenance
  skip_before_action :check_user_account_complete

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
    render "errors/maintenance", formats: :html
  end
end
