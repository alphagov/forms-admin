class PageConditionsService
  attr_reader :page

  def initialize(form:, pages:, page:)
    @form = form
    @pages = pages
    @page = page
  end

  def check_conditions
    form_conditions.select { |condition| condition.check_page_id == page.id }
  end

  delegate :routing_conditions, to: :page

private

  def form_conditions
    @form_conditions ||= @pages.flat_map(&:routing_conditions).compact_blank
  end
end
