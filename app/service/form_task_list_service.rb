class FormTaskListService
  include Rails.application.routes.url_helpers

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(form:)
    @form = form
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
                      new_page_path(@form.id)
                    end
    [
      { task_name: I18n.t("forms.task_lists.section_1.change_name"), path: change_form_name_path(@form.id), status: section_1_statuses[0] },
      { task_name: I18n.t("forms.task_lists.section_1.add_or_edit_questions"), path: question_path, status: section_1_statuses[1] },
      { task_name: I18n.t("forms.task_lists.section_1.declaration"), path: declaration_path(@form.id), status: section_1_statuses[2] },
      { task_name: I18n.t("forms.task_lists.section_1.add_what_happens_next"), path: what_happens_next_path(@form.id), status: section_1_statuses[3] },
    ]
  end

  def section_2_tasks
    hint_text = I18n.t("forms.task_lists.section_2.hint_text", submission_email: @form.submission_email) if @form.submission_email.present?

    [{ task_name: I18n.t("forms.task_lists.section_2.submission_email"), path: change_form_email_path(@form.id), hint_text:, status: section_2_statuses[0]  }]
  end

  def section_3_tasks
    [
      { task_name: I18n.t("forms.task_lists.section_3.privacy_policy"), path: privacy_policy_path(@form.id), status: section_3_statuses[0] },
      { task_name: I18n.t("forms.task_lists.section_3.contact_details"), path: contact_details_path(@form.id), status: section_3_statuses[1] },
    ]
  end

  def section_4_tasks
    return [] if @form.live?
    return [{ task_name: I18n.t("forms.task_lists.section_4.make_live"), path: make_live_path(@form.id), status: :not_started }] if @form.ready_for_live?

    [{ task_name: I18n.t("forms.task_lists.section_4.make_live"), path: "", active: false, status: :cannot_start }]
  end

  def section_1_statuses
    pages_status = if @form.question_section_completed
                     :completed
                   elsif @form.pages.any?
                     :in_progress
                   else
                     :incomplete
                   end

    declaration_status = if @form.declaration_section_completed
                           :completed
                         else
                           :incomplete
                         end

    what_happens_next_status = if @form.what_happens_next_text.present?
                                 :completed
                               else
                                 :incomplete
                               end
    results = []
    results << :completed
    results << pages_status
    results << declaration_status
    results << what_happens_next_status

    results
  end

  def section_2_statuses
    submission_status = if @form.submission_email.present?
                          :completed
                        else
                          :incomplete
                        end

    results = []
    results << submission_status
    results
  end

  def section_3_statuses
    privacy_policy_status = if @form.privacy_policy_url.present?
                              :completed
                            else
                              :incomplete
                            end

    support_contact_details = if @form.support_email.present? || @form.support_phone.present? || (@form.support_url_text.present? && @form.support_url)
                                :completed
                              else
                                :incomplete
                              end

    results = []
    results << privacy_policy_status
    results << support_contact_details
    results
  end
end
