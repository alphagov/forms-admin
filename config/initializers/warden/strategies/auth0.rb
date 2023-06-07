Warden::Strategies.add(:auth0) do
  def valid?
    env["omniauth.auth"].present?
  end

  def authenticate!
    logger.debug("Authenticating with auth0 strategy")

    user = prep_user(request.env["omniauth.auth"])
    fail!("Couldn't process credentials") unless user
    success!(user)
  end

private

  def prep_user(auth_hash)
    User.find_for_auth(
      provider: auth_hash[:provider],
      uid: auth_hash[:uid],
      email: auth_hash[:info][:email],
    )
  end
end
