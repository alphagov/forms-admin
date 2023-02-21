class FormsController < ApplicationController
  include CheckFormOrganisation

  rescue_from ActiveResource::ResourceNotFound do
    render template: "errors/not_found", status: :not_found
  end

  def index
    @forms = Form.all(params: { org: @current_user.organisation_slug }) || []
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
    @mark_complete_options = [OpenStruct.new(value: "true"), OpenStruct.new(value: "false")]

    if @mark_complete_form.valid?
      @form.question_section_completed = @mark_complete_form.mark_complete
      if @form.save
        redirect_to form_path(@form)
      else
        raise StandardError, "Save unsuccessful"
      end
    else
      render "pages/index", status: :unprocessable_entity
    end
  rescue StandardError => e
    flash[:message] = e
    render "pages/index", status: :unprocessable_entity
  end

private

  def mark_complete_form_params
    params.require(:forms_mark_complete_form).permit(:mark_complete)
  end
end
