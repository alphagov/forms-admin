class UserIdentificationForm < BaseForm
  attr_accessor :user, :name, :organisation_id

  validates :name, presence: true
  validates :organisation_id, presence: true

  def submit
    return false if invalid?

    user.name = name
    user.organisation_id = organisation_id
    user.save!
  end

  def assign_form_values
    self.name = user.name
    self.organisation_id = user.organisation_id
    self
  end
end
