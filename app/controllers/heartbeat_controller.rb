class HeartbeatController < ApplicationController
  skip_before_action :authenticate, :check_access

  def ping
    render(body: "PONG")
  end
end
