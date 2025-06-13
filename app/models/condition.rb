class Condition < ApplicationRecord
  belongs_to :routing_page, class_name: "Page"
  belongs_to :check_page, class_name: "Page", optional: true
  belongs_to :goto_page, class_name: "Page", optional: true

  has_one :form, through: :routing_page
end
