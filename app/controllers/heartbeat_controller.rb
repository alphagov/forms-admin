class HeartbeatController < ApplicationController
  skip_before_action :authenticate

  def ping
    render(body: "PONG")
  end
end
