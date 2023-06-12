class HeartbeatController < ApplicationController
  skip_before_action :authenticate_and_check_access, :check_maintenance_mode_is_enabled

  def ping
    render(body: "PONG")
  end
end
