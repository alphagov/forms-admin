class Forms::BaseController < ApplicationController
  rescue_from ActiveResource::ResourceNotFound, with: :render_not_found_error

  def current_form
    Form.find(params[:id])
  end

  def render_not_found_error
    render "forms/not_found", status: :not_found, formats: :html
  end

  helper_method :current_form
end
