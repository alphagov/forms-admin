class PageSummaryCardDataService
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
      rows: PageOptionsService.call(page: @page, pages: @pages).all_options_for_answer_type,

    }
  end

private

  def build_title
    # if a file upload question has guidance text, we want to display the guidance text in the title. Otherwise we display the question text
    if @page.answer_type == "file" && @page.guidance_markdown.present?
      if @page.is_optional?
        return "#{page_number(@page)}. #{@page.page_heading} (optional)"
      end
      return "#{page_number(@page)}. #{@page.page_heading}" if @page.answer_type == "file" && @page.guidance_markdown.present?
    end

    return "#{page_number(@page)}. #{@page.question_text}" unless @page.is_optional? && @page.answer_type != "selection"

    "#{page_number(@page)}. #{@page.question_text} (optional)"
  end

  def page_number(page)
    @pages.find_index(page) + 1
  end
end
