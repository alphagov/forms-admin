class ErrorsController < WebController
  skip_before_action :authenticate_and_check_access, except: :forbidden
  skip_before_action :check_maintenance_mode_is_enabled, only: :maintenance
  skip_before_action :redirect_if_account_not_completed

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
