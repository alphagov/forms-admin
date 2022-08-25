class FormsController < ApplicationController
  def show
    @form = Form.find(params[:id])
    @pages = @form.pages
    create_form_task_list
  end

private

  def form_params
    params.require(:form).permit(:name, :submission_email)
  end

  def create_form_task_list
    @question_path = if @form.pages.any?
                       form_pages_path(@form)
                     else
                       new_page_path(@form)
                     end

    @task_list = [{ title: "Create your form",
                    rows: [
                      { task_name: "Edit the name of your form", path: change_form_name_path(@form) },
                      { task_name: t("forms.form_overview.add_or_edit_questions"), path: @question_path },
                    ] },
                  { title: "Set email address for completed forms",
                    rows: [
                      { task_name: "Set the email address completed forms will be sent to", path: change_form_email_path(@form.id) },
                    ] },
                  { title: "Provide privacy and contact details",
                    rows: [
                      { task_name: "Provide a link to privacy information for this form", path: privacy_policy_path(@form.id) },
                    ] }]
  end
end
