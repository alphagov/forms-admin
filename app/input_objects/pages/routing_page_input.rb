class Pages::RoutingPageInput < BaseInput
  attr_accessor :routing_page_id, :form

  validates :routing_page_id, presence: true

  def initialize(attributes = {})
    super(attributes)
  end
end
