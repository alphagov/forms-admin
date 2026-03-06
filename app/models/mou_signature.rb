class MouSignature < ApplicationRecord
  belongs_to :user
  belongs_to :organisation, optional: true

  validates :agreed, acceptance: { message: lambda do |record, _|
    I18n.t("activerecord.errors.models.mou_signature.attributes.agreed.#{record.agreement_type}")
  end }

  enum :agreement_type, {
    crown: "crown",
    non_crown: "non_crown",
  }

  def self.add_mou_signature_organisation(user)
    mous_without_organisations = MouSignature.where(user:, organisation: nil)
    mous_without_organisations.update!(organisation_id: user.organisation.id)
  end
end
