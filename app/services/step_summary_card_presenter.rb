class StepSummaryCardPresenter
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(page:, pages:)
    @page = page
    @pages = pages
  end

  def build_data
    {
      card: {
        title: build_title,
        classes: "app-summary-card",
      },
      rows: StepSummaryCardService.call(page: @page, pages: @pages).all_options_for_answer_type,

    }
  end

private

  def build_title
    page_number = page_number(@page)
    heading = @page.page_heading
    question = @page.question_text

    # Use the actual heading instead of the question text for the title on file upload type
    title = if @page.answer_type == "file" && heading.present?
              "#{page_number}. #{heading}"
            else
              "#{page_number}. #{question}"
            end

    title += " (optional)" if @page.is_optional? && @page.answer_type != "selection"

    title
  end

  def page_number(page)
    @pages.find_index(page) + 1
  end
end
