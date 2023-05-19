class HeartbeatController < ApplicationController
  skip_before_action :authenticate_and_check_access

  def ping
    render(body: "PONG")
  end
end
