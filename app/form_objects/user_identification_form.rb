class UserIdentificationForm < BaseForm
  attr_accessor :user, :name, :organisation_id, :organisation_from_domain

  validates :name, presence: true
  validates :organisation_id, presence: true, if: -> { organisation_from_domain.blank? }

  def submit
    return false if invalid?

    user.name = name
    user.organisation_id = organisation_id
    user.save!
  end

  def assign_form_values
    self.name = user.name

    if user.organisation_id.blank?
      if organisation_from_domain.present?
        self.organisation_id = organisation_from_domain&.id
      end
    else
      self.organisation_id = user.organisation_id
    end

    self
  end

  def organisation_from_domain
    user_domain = user.email.split('@').last
    Organisation.where("domains @> ?", "{#{user_domain}}").first
  end
end
