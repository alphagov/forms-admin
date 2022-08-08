class FormsController < ApplicationController
  def show
    @form = Form.find(params[:id])
    @pages = @form.pages
  end

private

  def form_params
    params.require(:form).permit(:name, :submission_email)
  end
end
