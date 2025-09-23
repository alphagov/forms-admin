class Api::ErrorsController < ApplicationController
  def not_found
    render json: { error: "not_found" }, status: :not_found
  end

  def internal_server_error
    render json: { error: "internal_server_error" }, status: :internal_server_error
  end
end
