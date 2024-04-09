class HeartbeatController < ApplicationController
  skip_before_action :authenticate_and_check_access, :check_maintenance_mode_is_enabled, :clear_draft_questions_data, :redirect_if_account_not_completed

  def ping
    render(body: "PONG")
  end
end
