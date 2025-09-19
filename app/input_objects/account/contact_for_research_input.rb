class Account::ContactForResearchInput < BaseInput
  attr_accessor :user, :research_contact_status

  RADIO_OPTIONS = %w[consented declined].freeze

  validates :research_contact_status, presence: true, inclusion: { in: RADIO_OPTIONS }

  def submit
    return false if invalid?

    user.research_contact_status = research_contact_status
    user.user_research_opted_in_at = Time.zone.now
    user.save!
  end

  def values
    RADIO_OPTIONS
  end
end
