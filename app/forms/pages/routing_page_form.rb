class Pages::RoutingPageForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :routing_page_id

  validates :routing_page_id, presence: true
end
