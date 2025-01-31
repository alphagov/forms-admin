class PageRoutesService
  attr_reader :page

  def initialize(form:, pages:, page:)
    @form = form
    @pages = pages
    @page = page
  end

  def routes
    check_conditions
  end

private

  def check_conditions
    page_conditions_service.check_conditions
  end

  def page_conditions_service
    @page_conditions_service ||= PageConditionsService.new(form: @form, pages: @pages, page: @page)
  end
end
