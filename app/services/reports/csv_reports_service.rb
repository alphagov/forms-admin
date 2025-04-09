require "csv"

class Reports::CsvReportsService
  FORM_CSV_HEADERS = [
    "Form ID",
    "Status",
    "Form name",
    "Slug",
    "Organisation name",
    "Organisation ID",
    "Group name",
    "Group ID",
    "Created at",
    "Updated at",
    "Number of questions",
    "Has routes",
    "Payment URL",
    "Support URL",
    "Support URL text",
    "Support email",
    "Support phone",
    "Privacy policy URL",
    "What happens next markdown",
    "Submission type",
  ].freeze

  IS_REPEATABLE = "Is repeatable?".freeze
  QUESTIONS_CSV_HEADERS = [
    "Form ID",
    "Status",
    "Form name",
    "Organisation name",
    "Organisation ID",
    "Group name",
    "Group ID",
    "Question number in form",
    "Question text",
    "Answer type",
    "Hint text",
    "Page heading",
    "Guidance markdown",
    "Is optional?",
    IS_REPEATABLE,
    "Has routes?",
    "Answer settings - Input type",
    "Selection settings - Only one option?",
    "Selection settings - Number of options",
    "Name settings - Title needed?",
    "Raw answer settings",
  ].freeze

  IS_REPEATABLE_COLUMN_INDEX = QUESTIONS_CSV_HEADERS.find_index(IS_REPEATABLE)

  def live_forms_csv
    CSV.generate do |csv|
      csv << FORM_CSV_HEADERS

      Reports::FormDocumentsService.live_form_documents.each do |form_document|
        csv << form_row(form_document)
      end
    end
  end

  def live_forms_with_routes_csv
    CSV.generate do |csv|
      csv << FORM_CSV_HEADERS

      Reports::FormDocumentsService.live_form_documents.each do |form_document|
        csv << form_row(form_document) if Reports::FormDocumentsService.has_routes?(form_document)
      end
    end
  end

  def live_forms_with_payments_csv
    CSV.generate do |csv|
      csv << FORM_CSV_HEADERS

      Reports::FormDocumentsService.live_form_documents.each do |form_document|
        csv << form_row(form_document) if Reports::FormDocumentsService.has_payments?(form_document)
      end
    end
  end

  def live_forms_with_csv_submission_enabled_csv
    CSV.generate do |csv|
      csv << FORM_CSV_HEADERS

      Reports::FormDocumentsService.live_form_documents.each do |form_document|
        csv << form_row(form_document) if Reports::FormDocumentsService.has_csv_submission_enabled?(form_document)
      end
    end
  end

  def live_questions_csv(answer_type: nil)
    CSV.generate do |csv|
      csv << QUESTIONS_CSV_HEADERS

      Reports::FormDocumentsService.live_form_documents.each do |form_document|
        question_rows = question_rows(form_document, answer_type).compact

        question_rows.each do |question|
          csv << question
        end
      end
    end
  end

  def live_questions_with_add_another_answer_csv
    CSV.generate do |csv|
      csv << QUESTIONS_CSV_HEADERS

      Reports::FormDocumentsService.live_form_documents.each do |form_document|
        question_rows = question_rows(form_document, nil).compact

        question_rows.each do |question|
          csv << question if question[IS_REPEATABLE_COLUMN_INDEX]
        end
      end
    end
  end

private

  def form_row(form)
    form_id = form["form_id"]
    group = GroupForm.find_by_form_id(form_id)&.group
    [
      form_id,
      form["tag"],
      form["content"]["name"],
      form["content"]["form_slug"],
      group&.organisation&.name,
      group&.organisation&.id,
      group&.name,
      group&.external_id,
      form["content"]["created_at"],
      form["content"]["updated_at"],
      form["content"]["steps"].length,
      form["content"]["steps"].any? { |step| step["routing_conditions"].present? },
      form["content"]["payment_url"],
      form["content"]["support_url"],
      form["content"]["support_url_text"],
      form["content"]["support_email"],
      form["content"]["support_phone"],
      form["content"]["privacy_policy_url"],
      form["content"]["what_happens_next_markdown"],
      form["content"]["submission_type"],
    ]
  end

  def question_rows(form, answer_type)
    form_id = form["form_id"]
    group = GroupForm.find_by_form_id(form_id)&.group

    form["content"]["steps"].each_with_index.map do |step, index|
      next if answer_type.present? && step["data"]["answer_type"] != answer_type

      [
        form_id,
        form["tag"],
        form["content"]["name"],
        group&.organisation&.name,
        group&.organisation&.id,
        group&.name,
        group&.external_id,
        index + 1,
        step["data"]["question_text"],
        step["data"]["answer_type"],
        step["data"]["hint_text"],
        step["data"]["page_heading"],
        step["data"]["guidance_markdown"],
        step["data"]["is_optional"],
        step["data"]["is_repeatable"],
        step["routing_conditions"].present?,
        step.dig("data", "answer_settings", "input_type"),
        step.dig("data", "answer_settings", "only_one_option").presence.try { |o| o.to_s == "true" },
        step.dig("data", "answer_settings", "selection_options")&.length,
        step.dig("data", "answer_settings", "title_needed"),
        step["data"]["answer_settings"].as_json,
      ]
    end
  end
end
