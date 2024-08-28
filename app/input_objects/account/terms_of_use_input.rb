class Account::TermsOfUseInput < BaseInput
  attr_accessor :user, :agreed

  validates :agreed, acceptance: true

  def submit
    return false if invalid?

    user.terms_agreed_at = Time.zone.now

    user.save!
  end
end
