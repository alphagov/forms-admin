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

  def edit
    @form = Form.find(params[:id])
  end

  def update
    form = Form.find(params[:id])

    form.name = form_params[:name]
    form.submission_email = form_params[:submission_email]
    form.org = current_user.organisation_slug

    form.save!

    flash[:message] = "Successfully updated!"
    redirect_to action: "show", id: form.id
  rescue StandardError
    flash[:message] = "Update unsuccessful"
    redirect_to :edit_form, id: params[:id]
  end

  def delete
    @form = Form.find(params[:form_id])
  end

  def destroy
    form = Form.find(params[:id])
    if form.destroy
      flash[:message] = "Successfully deleted #{form.name}"
      redirect_to root_path, status: :see_other
    else
      raise StandardError, "Deletion unsuccessful"
    end
  rescue StandardError
    flash[:message] = "Deletion unsuccessful"
    redirect_to :form, id: params[:id]
  end

  def render_not_found_error
    render "not_found", status: :not_found, formats: :html
  end

private

  def form_params
    params.require(:form).permit(:name, :submission_email)
  end
end
