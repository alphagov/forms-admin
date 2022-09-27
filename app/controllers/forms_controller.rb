class FormsController < ApplicationController
  rescue_from ActiveResource::ResourceNotFound do
    render template: "errors/not_found", status: :not_found
  end

  def show
    @form = Form.find(params[:id])
    @task_list = FormTaskListService.call(form: @form).all_tasks
  end

private

  def form_params
    params.require(:form).permit(:name, :submission_email)
  end
end
