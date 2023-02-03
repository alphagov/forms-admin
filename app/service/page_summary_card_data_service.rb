class PageSummaryCardDataService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(page:)
    @page = page
  end

  def build_data
    {
      title: build_title,
      rows: PageOptionsService.call(page: @page).all_options_for_answer_type,
    }
  end

private

  def build_title
    return @page.question_text unless @page.is_optional? || @page.answer_type == "selection"

    "#{@page.question_text} (optional)"
  end
end
