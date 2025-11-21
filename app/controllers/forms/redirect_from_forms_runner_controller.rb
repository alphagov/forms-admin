class Forms::RedirectFromFormsRunnerController < WebController
  before_action :check_user_has_permission
  after_action :verify_authorized

  def edit_question
    page_external_id = params.require(:page_external_id)
    page = current_form.pages.find_by!(external_id: page_external_id)
    redirect_to edit_question_path(current_form.id, page.id)
  end

  def routes
    page_external_id = params.require(:page_external_id)
    page = current_form.pages.find_by!(external_id: page_external_id)
    redirect_to show_routes_path(current_form.id, page.id)
  end

private

  def check_user_has_permission
    authorize current_form, :can_edit_form?
  end
end
