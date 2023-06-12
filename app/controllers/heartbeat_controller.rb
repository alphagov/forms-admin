class HeartbeatController < ApplicationController
  skip_before_action :authenticate_and_check_access, :check_service_unavailable

  def ping
    render(body: "PONG")
  end
end
