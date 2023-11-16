Warden::Strategies.add(:mock_user) do
  def authenticate!
    logger.warn("Authenticating with mock_gds_sso strategy")

    test_user ||= User.first

    if test_user
      success!(test_user)
    elsif Rails.env.test? && ENV["GDS_SSO_MOCK_INVALID"].present?
      fail!(:invalid)
    else
      raise "Mock_user running in mock mode and no test user found. Normally we'd load the first user in the database. Create a user in the database."
    end
  end
end
