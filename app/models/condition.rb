class Condition < ApplicationRecord
  belongs_to :routing_page, class_name: "Page"
  belongs_to :check_page, class_name: "Page", optional: true
  belongs_to :goto_page, class_name: "Page", optional: true

  has_one :form, through: :routing_page

  before_destroy :destroy_postconditions

private

  def destroy_postconditions
    return if check_page.nil?

    postconditions = check_page.check_conditions.filter { it != self && it.routing_page_id != it.check_page_id }
    postconditions.each(&:destroy!)
  end
end
