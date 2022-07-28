class FormsController < ApplicationController
  rescue_from ActiveResource::ResourceNotFound, with: :render_not_found_error

  def show
    @form = Form.find(params[:id])
    @pages = @form.pages
  end

  def render_not_found_error
    render "not_found", status: :not_found, formats: :html
  end

private

  def form_params
    params.require(:form).permit(:name, :submission_email)
  end
end
