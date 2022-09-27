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
      { task_name: I18n.t("forms.task_lists.section_1.change_name"), path: change_form_name_path(@form.id) },
      { task_name: I18n.t("forms.task_lists.section_1.add_or_edit_questions"), path: question_path },
      { task_name: I18n.t("forms.task_lists.section_1.add_what_happens_next"), path: what_happens_next_path(@form.id) },
    ]
  end

  def section_2_tasks
    [{ task_name: I18n.t("forms.task_lists.section_2.submission_email"), path: change_form_email_path(@form.id) }]
  end

  def section_3_tasks
    [{ task_name: I18n.t("forms.task_lists.section_3.privacy_policy"), path: privacy_policy_path(@form.id) }]
  end

  def section_4_tasks
    return [] if @form.live?
    return [{ task_name: I18n.t("forms.task_lists.section_4.make_live"), path: make_live_path(@form.id) }] if @form.ready_for_live?

    [{ task_name: I18n.t("forms.task_lists.section_4.make_live"), path: "", active: false }]
  end
end
