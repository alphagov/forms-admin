class ErrorsController < ApplicationController
  # We are safe to authenitcate forbidden errors as the user must be logged in
  # to get to this point
  skip_before_action :authenticate, only: %i[not_found internal_server_error]

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def forbidden
    render status: :forbidden
  end
end
