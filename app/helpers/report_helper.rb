module ReportHelper
  def report_table(records)
    type = records.first.fetch("type", "form")

    if type == "form"
      with_routes = records.first.dig("metadata", "number_of_routes").present?

      with_routes ? report_forms_with_routes_table(records) : report_forms_table(records)
    elsif type == "question_page"
      report_questions_table(records)
    else
      raise "type of records '#{type}' is not one of 'forms', 'question_page'"
    end
  end

  def report_forms_table(forms)
    {
      head: report_forms_table_head,
      rows: report_forms_table_rows(forms),
    }
  end

  def report_forms_with_routes_table(forms)
    {
      head: report_forms_with_routes_table_head,
      rows: report_forms_with_routes_table_rows(forms),
    }
  end

  def report_questions_table(questions)
    {
      head: report_questions_table_head,
      rows: report_questions_table_rows(questions),
    }
  end

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
      I18n.t("reports.form_or_questions_list_table.headings.number_of_branch_routes"),
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
      form_link(form),
      form["organisation_name"],
    ]
  end

  def report_forms_with_routes_table_row(form)
    [
      *report_forms_table_row(form),
      form["metadata"]["number_of_routes"].to_s,
      form["metadata"]["number_of_branch_routes"].to_s,
    ]
  end

  def report_questions_table_row(question)
    [
      *report_forms_table_row(question["form"]),
      question["data"]["question_text"],
    ]
  end

  def form_link(form)
    form_id = form["form_id"]
    form_name = form["content"]["name"]
    pages_path = case form["tag"]
                 when "draft"
                   form_pages_path(form_id:)
                 when "live"
                   live_form_pages_path(form_id:)
                 else
                   raise "tag of form record '#{form['tag']}' is not expected"
                 end

    govuk_link_to(form_name, pages_path)
  end
end
