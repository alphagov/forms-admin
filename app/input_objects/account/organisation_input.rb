class Account::OrganisationInput < BaseInput
  attr_accessor :user, :organisation_id

  validates :organisation_id, presence: true

  def submit
    return false if invalid?

    user.organisation_id = organisation_id

    if user.save!
      log_organisation_chosen_event
      true
    end
  end

  def assign_form_values
    self.organisation_id = user.organisation_id
    self
  end

private

  def log_organisation_chosen_event
    EventLogger.log({
      event: "organisation_chosen",
      user_id: user.id,
      organisation_id:,
    })
  end
end
