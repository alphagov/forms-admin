class FormTaskListService
  include Rails.application.routes.url_helpers

  attr_reader :task_counts

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(form:, current_user:)
    @current_user = current_user
    @form = form
    @task_statuses = form.all_task_statuses
    @task_counts = status_counts
  end

  def all_sections
    [
      section_1,
      section_2,
      section_3,
      section_4,
    ]
  end

private

  def create_or_edit
    @form.has_live_version ? "edit" : "create"
  end

  def section_1
    {
      title: I18n.t("forms.task_list_#{create_or_edit}.section_1.title"),
      rows: section_1_tasks,
    }
  end

  def section_1_tasks
    question_path = if @form.pages.any?
                      form_pages_path(@form.id)
                    else
                      start_new_question_path(@form.id)
                    end
    [
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.section_1.name"), path: change_form_name_path(@form.id), status: @task_statuses[:name_status] },
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.section_1.questions"), path: question_path, status: @task_statuses[:pages_status] },
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.section_1.declaration"), path: declaration_path(@form.id), status: @task_statuses[:declaration_status] },
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.section_1.what_happens_next"), path: what_happens_next_path(@form.id), status: @task_statuses[:what_happens_next_status] },
    ]
  end

  def section_2
    section = {
      title: I18n.t("forms.task_list_#{create_or_edit}.section_2.title"),
    }

    if Pundit.policy(@current_user, @form).can_change_form_submission_email?
      section[:rows] = section_2_tasks
    else
      section[:body_text] = I18n.t(
        "forms.task_list_create.section_2.if_not_permitted.body_text",
        submission_email: @form.submission_email,
      )
    end

    section
  end

  def section_2_tasks
    hint_text = I18n.t("forms.task_list_#{create_or_edit}.section_2.hint_text_html", submission_email: @form.submission_email) if @form.submission_email.present?
    [{ task_name: I18n.t("forms.task_list_#{create_or_edit}.section_2.email"), path: submission_email_form_path(@form.id), hint_text:, status: @task_statuses[:submission_email_status] },
     { task_name: I18n.t("forms.task_list_#{create_or_edit}.section_2.confirm_email"), path: submission_email_code_path(@form.id), status: @task_statuses[:confirm_submission_email_status], active: can_enter_submission_email_code }]
  end

  def section_3
    {
      title: I18n.t("forms.task_list_#{create_or_edit}.section_3.title"),
      rows: section_3_tasks,
    }
  end

  def section_3_tasks
    [
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.section_3.privacy_policy"), path: privacy_policy_path(@form.id), status: @task_statuses[:privacy_policy_status] },
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.section_3.contact_details"), path: contact_details_path(@form.id), status: @task_statuses[:support_contact_details_status] },
    ]
  end

  def section_4
    section = {
      title: I18n.t("forms.task_list_#{create_or_edit}.section_4.title"),
    }

    if Pundit.policy(@current_user, @form).can_make_form_live?
      section[:rows] = section_4_tasks
    else
      section[:body_text] = I18n.t("forms.task_list_create.section_4.if_not_permitted.body_text")
    end

    section
  end

  def section_4_tasks
    [{
      task_name: I18n.t("forms.task_list_#{create_or_edit}.section_4.make_live"),
      path: @form.all_ready_for_live? ? make_live_path(@form.id) : "",
      status: @task_statuses[:make_live_status],
      active: @form.all_ready_for_live?,
    }]
  end

  def statuses_by_user
    statuses = @task_statuses

    statuses.delete(:submission_email_status) unless Pundit.policy(@current_user, @form).can_change_form_submission_email?
    statuses.delete(:confirm_submission_email_status) unless Pundit.policy(@current_user, @form).can_change_form_submission_email?
    statuses.delete(:make_live_status) unless Pundit.policy(@current_user, @form).can_make_form_live?

    statuses
  end

  def status_counts
    filtered_statuses = statuses_by_user.compact
    { completed: filtered_statuses.count { |_key, value| value == :completed },
      total: filtered_statuses.count }
  end

  def can_enter_submission_email_code
    @form.email_confirmation_status == :sent
  end
end
