require "warden/strategies/omniauth"

Warden::Strategies.add(:cddo_sso) do
  include Warden::Strategies::OmniAuth

private

  def prep_user(auth_hash)
    User.find_for_auth(
      provider: auth_hash[:provider],
      uid: auth_hash[:uid],
      email: auth_hash[:info][:email],
      name: auth_hash[:info][:name],
    )
  end
end
