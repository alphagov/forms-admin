class HeartbeatController < ApplicationController
  skip_before_action :authenticate_user!

  def ping
    render(body: "PONG")
  end
end
