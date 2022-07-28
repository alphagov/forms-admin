class FormsController < ApplicationController
  rescue_from ActiveResource::ResourceNotFound, with: :render_not_found_error

  def new; end

  def create
    form = Form.new({
      name: params[:name],
      submission_email: params[:submission_email],
      org: current_user.organisation_slug,
    })

    form.save!

    flash[:message] = "Successfully created!"
    redirect_to action: "show", id: form.id
  rescue StandardError
    flash[:message] = "Unsuccessful"
    render :new
  end

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
