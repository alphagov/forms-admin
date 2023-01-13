class FormTaskListService
  include Rails.application.routes.url_helpers

  attr_reader :task_counts

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(form:)
    @form = form
    @task_list_statuses = TaskStatusService.new(form: @form)
    @task_counts = @task_list_statuses.status_counts
  end

  def all_tasks
    [
      { title: I18n.t("forms.task_lists.section_1.title"), rows: section_1_tasks },
      { title: I18n.t("forms.task_lists.section_2.title"), rows: section_2_tasks },
      { title: I18n.t("forms.task_lists.section_3.title"), rows: section_3_tasks },
      { title: I18n.t("forms.task_lists.section_4.title"), rows: section_4_tasks },
    ]
  end

private

  def section_1_tasks
    question_path = if @form.pages.any?
                      form_pages_path(@form.id)
                    else
                      type_of_answer_new_path(@form.id)
                    end
    [
      { task_name: I18n.t("forms.task_lists.section_1.change_name"), path: change_form_name_path(@form.id), status: @task_list_statuses.name_status },
      { task_name: I18n.t("forms.task_lists.section_1.add_or_edit_questions"), path: question_path, status: @task_list_statuses.pages_status },
      { task_name: I18n.t("forms.task_lists.section_1.declaration"), path: declaration_path(@form.id), status: @task_list_statuses.declaration_status },
      { task_name: I18n.t("forms.task_lists.section_1.add_what_happens_next"), path: what_happens_next_path(@form.id), status: @task_list_statuses.what_happens_next_status },
    ]
  end

  def section_2_tasks
    hint_text = I18n.t("forms.task_lists.section_2.hint_text_html", submission_email: @form.submission_email) if @form.submission_email.present?
    [{ task_name: I18n.t("forms.task_lists.section_2.set_email"), path: submission_email_form_path(@form.id), hint_text:, status: @task_list_statuses.submission_email_status },
     { task_name: I18n.t("forms.task_lists.section_2.confirm_email"), path: submission_email_code_path(@form.id), status: @task_list_statuses.confirm_submission_email_status, active: @task_list_statuses.can_enter_submission_email_code }]
  end

  def section_3_tasks
    [
      { task_name: I18n.t("forms.task_lists.section_3.privacy_policy"), path: privacy_policy_path(@form.id), status: @task_list_statuses.privacy_policy_status },
      { task_name: I18n.t("forms.task_lists.section_3.contact_details"), path: contact_details_path(@form.id), status: @task_list_statuses.support_contact_details_status },
    ]
  end

  def section_4_tasks
    return [] if @form.live?

    [{
      task_name: I18n.t("forms.task_lists.section_4.make_live"),
      path: @form.ready_for_live? ? make_live_path(@form.id) : "",
      status: @task_list_statuses.make_live_status,
      active: @task_list_statuses.mandatory_tasks_completed?,
    }]
  end
end
