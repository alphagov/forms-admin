class MouSignature < ApplicationRecord
  belongs_to :user
  belongs_to :organisation, optional: true

  def self.update_user_orgs(user)
    MouSignature.where(user:, organisation: nil).update_all(organisation_id: user.organisation.id)
  end
end
