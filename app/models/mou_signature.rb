class MouSignature < ApplicationRecord
  belongs_to :user
  belongs_to :organisation, optional: true

  validates :agreed, acceptance: true

  def self.add_mou_signature_organisation(user)
    mous_without_organisations = MouSignature.where(user:, organisation: nil)
    mous_without_organisations.update!(organisation_id: user.organisation.id)
  end
end
