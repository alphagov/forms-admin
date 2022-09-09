class FormsController < ApplicationController
  def show
    @form = Form.find(params[:id])
    create_form_task_list
    @form_is_live = @form.live_at && @form.live_at < Time.now
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

    @task_list = [{ title: t("forms.task_lists.section_1.title"),
                    rows: [
                      { task_name: t("forms.task_lists.section_1.change_name"), path: change_form_name_path(@form) },
                      { task_name: t("forms.task_lists.section_1.add_or_edit_questions"), path: @question_path },
                    ] },
                  { title: t("forms.task_lists.section_2.title"),
                    rows: [
                      { task_name: t("forms.task_lists.section_2.submission_email"), path: change_form_email_path(@form.id) },
                    ] },
                  { title: t("forms.task_lists.section_3.title"),
                    rows: [
                      { task_name: t("forms.task_lists.section_3.privacy_policy"), path: privacy_policy_path(@form.id) },
                    ] }]

    unless @form.live?
      @task_list.append({ title: t("forms.task_lists.section_4.title"),
                          rows: [
                            { task_name: t("forms.task_lists.section_4.make_live"), path: make_live_path(@form.id) },
                          ] })
    end
  end
end
