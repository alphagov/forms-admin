class Pages::RoutingPageForm < BaseForm
  attr_accessor :routing_page_id

  validates :routing_page_id, presence: true
end
