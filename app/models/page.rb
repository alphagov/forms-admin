class Page < ApplicationRecord
  belongs_to :form
  has_many :routing_conditions, class_name: "Condition", foreign_key: "routing_page_id", dependent: :destroy
  has_many :check_conditions, class_name: "Condition", foreign_key: "check_page_id", dependent: :destroy
  has_many :goto_conditions, class_name: "Condition", foreign_key: "goto_page_id", dependent: :destroy

  ANSWER_TYPES = %w[name organisation_name email phone_number national_insurance_number address date selection number text file].freeze

  ANSWER_TYPES_WITHOUT_SETTINGS = %w[organisation_name email phone_number national_insurance_number number].freeze

  ANSWER_TYPES_WITH_SETTINGS = %w[selection text date address name].freeze
end
