class FormsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  def index
    @forms = policy_scope(Form) || []
  end

  def show
    authorize current_form, :can_view_form?
    @form = current_form
    task_service = FormTaskListService.call(form: @form, current_user:)
    @task_list = task_service.all_sections
    @task_status_counts = task_service.task_counts
  end

  def mark_pages_section_completed
    authorize current_form, :can_view_form?
    @form = current_form
    @pages = @form.pages
    @mark_complete_form = Forms::MarkCompleteForm.new(mark_complete_form_params)

    if @mark_complete_form.mark_section
      success_message = if @mark_complete_form.mark_complete == "true"
                          t("banner.success.form.pages_saved_and_section_completed")
                        else
                          t("banner.success.form.pages_saved")
                        end
      redirect_to form_path(@form), success: success_message
    else
      @mark_complete_form.mark_complete = "false"
      render "pages/index", status: :unprocessable_entity
    end
  end

private

  def current_form
    @current_form ||= Form.find(params[:form_id])
  end

  def mark_complete_form_params
    params.require(:forms_mark_complete_form).permit(:mark_complete).merge(form: @form)
  end
end
