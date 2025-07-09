class Page < ApplicationRecord
  self.ignored_columns += %w[next_page]

  before_destroy :destroy_secondary_skip_conditions

  belongs_to :form
  has_many :routing_conditions, class_name: "Condition", foreign_key: "routing_page_id", dependent: :destroy
  has_many :check_conditions, class_name: "Condition", foreign_key: "check_page_id", dependent: :destroy
  has_many :goto_conditions, class_name: "Condition", foreign_key: "goto_page_id", dependent: :destroy
  acts_as_list scope: :form

  ANSWER_TYPES = %w[name organisation_name email phone_number national_insurance_number address date selection number text file].freeze

  ANSWER_TYPES_WITHOUT_SETTINGS = %w[organisation_name email phone_number national_insurance_number number].freeze

  ANSWER_TYPES_WITH_SETTINGS = %w[selection text date address name].freeze

private

  def destroy_secondary_skip_conditions
    return if goto_conditions.empty?

    # We want to delete the secondary skip for the page at the start of the route
    # That association isn't in the database, so we need to dig it out
    # TODO: what if the page owning the routes has more than two routes?
    goto_conditions
      .filter { |condition| condition.check_page_id == condition.routing_page_id }
      .map(&:check_page)
      .flat_map(&:check_conditions)
      .filter { |condition| condition.check_page_id != condition.routing_page_id }
      .each(&:destroy!)
  end
end
