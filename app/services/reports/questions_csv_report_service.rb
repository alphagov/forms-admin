require "csv"

class Reports::QuestionsCsvReportService
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

  attr_reader :form_documents

  def initialize(form_documents)
    @form_documents = form_documents
  end

  def questions_csv(answer_type: nil)
    CSV.generate do |csv|
      csv << QUESTIONS_CSV_HEADERS

      form_documents.each do |form_document|
        question_rows = question_rows(form_document, answer_type).compact

        question_rows.each do |question|
          csv << question
        end
      end
    end
  end

  def questions_with_add_another_answer_csv
    CSV.generate do |csv|
      csv << QUESTIONS_CSV_HEADERS

      form_documents.each do |form_document|
        question_rows = question_rows(form_document, nil).compact

        question_rows.each do |question|
          csv << question if question[IS_REPEATABLE_COLUMN_INDEX]
        end
      end
    end
  end

private

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
