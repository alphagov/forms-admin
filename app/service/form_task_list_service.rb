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
      create_form_section,
      payment_link_subsection,
      email_address_section,
      privacy_and_contact_details_section,
      make_form_live_section,
    ]
  end

private

  def create_or_edit
    return "edit" if @form.is_live?
    return "edit" if @form.is_archived?

    "create"
  end

  def create_form_section
    {
      title: I18n.t("forms.task_list_#{create_or_edit}.create_form_section.title"),
      rows: create_form_section_tasks,
      section_number: 1,
      subsection: false,
    }
  end

  def create_form_section_tasks
    question_path = if @form.pages.any?
                      form_pages_path(@form.id)
                    else
                      start_new_question_path(@form.id)
                    end
    [
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.create_form_section.name"), path: change_form_name_path(@form.id), status: @task_statuses[:name_status] },
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.create_form_section.questions"), path: question_path, status: @task_statuses[:pages_status] },
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.create_form_section.declaration"), path: declaration_path(@form.id), status: @task_statuses[:declaration_status] },
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.create_form_section.what_happens_next"), path: what_happens_next_path(@form.id), status: @task_statuses[:what_happens_next_status] },
    ]
  end

  def payment_link_subsection
    {
      title: I18n.t("forms.task_list_#{create_or_edit}.payment_link_subsection.title"),
      rows: payment_link_subsection_tasks,
      section_number: nil,
      subsection: true,
    }
  end

  def payment_link_subsection_tasks
    [
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.payment_link_subsection.payment_link"), path: payment_link_path(@form.id), status: @task_statuses[:payment_link_status] },
    ]
  end

  def email_address_section
    section = {
      title: I18n.t("forms.task_list_#{create_or_edit}.email_address_section.title"),
      section_number: 2,
      subsection: false,
    }

    if Pundit.policy(@current_user, @form).can_change_form_submission_email?
      section[:rows] = email_address_section_tasks
    else
      section[:body_text] = I18n.t(
        "forms.task_list_create.email_address_section.if_not_permitted.body_text",
        submission_email: @form.submission_email,
      )
    end

    section
  end

  def email_address_section_tasks
    hint_text = I18n.t("forms.task_list_#{create_or_edit}.email_address_section.hint_text_html", submission_email: @form.submission_email) if @form.submission_email.present?
    [{ task_name: I18n.t("forms.task_list_#{create_or_edit}.email_address_section.email"), path: submission_email_input_path(@form.id), hint_text:, status: @task_statuses[:submission_email_status] },
     { task_name: I18n.t("forms.task_list_#{create_or_edit}.email_address_section.confirm_email"), path: submission_email_code_path(@form.id), status: @task_statuses[:confirm_submission_email_status], active: can_enter_submission_email_code }]
  end

  def privacy_and_contact_details_section
    {
      title: I18n.t("forms.task_list_#{create_or_edit}.privacy_and_contact_details_section.title"),
      rows: privacy_and_contact_details_section_tasks,
      section_number: 3,
      subsection: false,
    }
  end

  def privacy_and_contact_details_section_tasks
    [
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.privacy_and_contact_details_section.privacy_policy"), path: privacy_policy_path(@form.id), status: @task_statuses[:privacy_policy_status] },
      { task_name: I18n.t("forms.task_list_#{create_or_edit}.privacy_and_contact_details_section.contact_details"), path: contact_details_path(@form.id), status: @task_statuses[:support_contact_details_status] },
    ]
  end

  def make_form_live_section
    section = {
      title: live_title_name,
      section_number: 4,
      subsection: false,
    }

    if Pundit.policy(@current_user, @form).can_make_form_live?
      section[:rows] = make_form_live_section_tasks
    else
      section[:body_text] = I18n.t("forms.task_list_create.make_form_live_section.if_not_permitted.body_text")
    end

    section
  end

  def make_form_live_section_tasks
    [{
      task_name: live_task_name,
      path: live_path,
      status: @task_statuses[:make_live_status],
      active: @form.all_ready_for_live?,
    }]
  end

  def live_title_name
    return I18n.t("forms.task_list_create.make_form_live_section.title") if @form.is_archived?

    I18n.t("forms.task_list_#{create_or_edit}.make_form_live_section.title")
  end

  def live_task_name
    return I18n.t("forms.task_list_create.make_form_live_section.make_live") if @form.is_archived?

    I18n.t("forms.task_list_#{create_or_edit}.make_form_live_section.make_live")
  end

  def live_path
    return "" unless @form.all_ready_for_live?

    make_live_path(@form.id)
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
    remove_optional_statuses(filtered_statuses)

    { completed: filtered_statuses.count { |_key, value| value == :completed },
      total: filtered_statuses.count }
  end

  def remove_optional_statuses(statuses)
    statuses.delete(:payment_link_status)
  end

  def can_enter_submission_email_code
    @form.email_confirmation_status == :sent
  end
end
