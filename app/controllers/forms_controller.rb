class FormsController < ApplicationController
  include CheckFormOrganisation

  rescue_from ActiveResource::ResourceNotFound do
    render template: "errors/not_found", status: :not_found
  end

  def index
    @forms = policy_scope(Form) || []
  end

  def show
    @form = Form.find(params[:form_id])
    task_service = FormTaskListService.call(form: @form)
    @task_list = task_service.all_tasks
    @task_status_counts = task_service.task_counts
  end

  def mark_pages_section_completed
    @form = Form.find(params[:form_id])
    @pages = @form.pages
    @mark_complete_form = Forms::MarkCompleteForm.new(mark_complete_form_params)

    if @mark_complete_form.mark_section
      redirect_to form_path(@form)
    else
      flash[:message] = "Save unsuccessful"
      render "pages/index", status: :unprocessable_entity
    end
  end

private

  def mark_complete_form_params
    params.require(:forms_mark_complete_form).permit(:mark_complete).merge(form: @form)
  end
end
