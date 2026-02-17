class StepSummaryCardPresenter
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(step:, steps:, welsh_steps: nil)
    @step = step
    @steps = steps
    @welsh_steps = welsh_steps
  end

  def build_card
    {
      title: build_title,
      classes: "app-summary-card",
    }
  end

  def build_summary_list
    {
      rows: StepSummaryCardService.call(step: @step, steps: @steps).all_options_for_answer_type,
    }
  end

  def build_bilingual_table
    {
      classes: %w[app-translation-table],
      head: [
        { text: nil, classes: "app-translation-table__empty-header-cell" },
        { text: I18n.t("forms.welsh_translation.new.english_header") },
        { text: I18n.t("forms.welsh_translation.new.welsh_header") },
      ],
      rows: StepSummaryTableService.call(step: @step, steps: @steps, welsh_steps: @welsh_steps).values_with_welsh_content,
      first_cell_is_header: true,
    }
  end

  def build_untranslated_content
    StepSummaryTableService.call(step: @step, steps: @steps, welsh_steps: @welsh_steps).untranslated_content
  end

private

  def build_title
    page_number = page_number(@step)
    heading = @step.page_heading
    question = @step.question_text

    # Use the actual heading instead of the question text for the title on file upload type
    title = if @step.answer_type == "file" && heading.present?
              "#{page_number}. #{heading}"
            else
              "#{page_number}. #{question}"
            end

    title += " (optional)" if @step.is_optional? && @step.answer_type != "selection"

    title += "<br><span lang=\"cy\" class=\"govuk-!-font-weight-regular\">#{build_title_cy}</span>" if welsh_step.present?

    ActionController::Base.helpers.sanitize(title)
  end

  def build_title_cy
    page_number = welsh_step.position
    heading = welsh_step.page_heading
    question = welsh_step.question_text

    # Use the actual heading instead of the question text for the title on file upload type
    title = if welsh_step.answer_type == "file" && heading.present?
              "#{page_number}. #{heading}"
            else
              "#{page_number}. #{question}"
            end

    title += " (dewisol)" if welsh_step.is_optional? && welsh_step.answer_type != "selection"

    title
  end

  def page_number(step)
    @steps.find_index(step) + 1
  end

  def welsh_step
    return nil if @welsh_steps.blank?

    @welsh_steps.find { |welsh_step| welsh_step.id == @step.id }
  end
end
