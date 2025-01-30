class Pages::RoutingPageInput < BaseInput
  attr_accessor :routing_page_id

  validate :routing_page_id_present

  def initialize(attributes = {}, branch_routing_enabled: false)
    @branch_routing_enabled = branch_routing_enabled
    super(attributes)
  end

private

  def blank_error_symbol
    if @branch_routing_enabled
      :blank
    else
      :branch_routing_disabled_blank
    end
  end

  def routing_page_id_present
    errors.add(:routing_page_id, blank_error_symbol) if routing_page_id.blank?
  end
end
