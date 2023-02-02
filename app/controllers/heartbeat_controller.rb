class HeartbeatController < ApplicationController
  skip_before_action :authenticate_with_basic_auth

  def ping
    render(body: "PONG")
  end
end
