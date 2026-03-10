class FormsController < WebController
  after_action :verify_authorized

  def show
    authorize current_form, :can_view_form?
    task_service = FormTaskListService.call(form: current_form, current_user:)
    @task_list = task_service.all_sections
    @task_status_counts = task_service.task_counts
    render :show, locals: { current_form: }
  end
end
