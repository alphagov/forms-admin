class MouSignature < ApplicationRecord
  belongs_to :user
  belongs_to :organisation, optional: true

  scope :without_organisations, -> { where(organisation: nil) }

  validates :agreed, acceptance: true
end
