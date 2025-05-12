module ReportHelper
  def report_forms_table_head
    [
      I18n.t("reports.form_or_questions_list_table.headings.form_name"),
      I18n.t("reports.form_or_questions_list_table.headings.organisation"),
    ]
  end

  def report_forms_table_rows(forms)
    forms.map { |form| report_forms_table_row(form) }
  end

  def report_forms_with_routes_table_head
    [
      *report_forms_table_head,
      I18n.t("reports.form_or_questions_list_table.headings.number_of_routes"),
    ]
  end

  def report_forms_with_routes_table_rows(forms)
    forms.map { |form| report_forms_with_routes_table_row(form) }
  end

  def report_questions_table_head
    [
      *report_forms_table_head,
      I18n.t("reports.form_or_questions_list_table.headings.question_text"),
    ]
  end

  def report_questions_table_rows(questions)
    questions.map { |question| report_questions_table_row(question) }
  end

private

  def report_forms_table_row(form)
    [
      govuk_link_to(form["content"]["name"], live_form_pages_path(form_id: form["form_id"])),
      form["group"]["organisation"]["name"],
    ]
  end

  def report_forms_with_routes_table_row(form)
    [
      *report_forms_table_row(form),
      form["metadata"]["number_of_routes"].to_s,
    ]
  end

  def report_questions_table_row(question)
    [
      *report_forms_table_row(question["form"]),
      question["data"]["question_text"],
    ]
  end
end
