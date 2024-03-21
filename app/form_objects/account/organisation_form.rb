class Account::OrganisationForm < BaseForm
  attr_accessor :user, :organisation_id

  validates :organisation_id, presence: true

  def submit
    return false if invalid?

    user.organisation_id = organisation_id
    user.save!
  end

  def assign_form_values
    self.organisation_id = user.organisation_id
    self
  end
end
