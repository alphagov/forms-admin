class StepSummaryCardPresenter
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(step:, steps:)
    @step = step
    @steps = steps
  end

  def build_data
    {
      card: {
        title: build_title,
        classes: "app-summary-card",
      },
      rows: StepSummaryCardService.call(step: @step, steps: @steps).all_options_for_answer_type,

    }
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

    title
  end

  def page_number(step)
    @steps.find_index(step) + 1
  end
end
