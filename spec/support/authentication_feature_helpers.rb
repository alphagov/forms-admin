module AuthenticationFeatureHelpers
  @cached_gds_sso_mock_invalid = ENV["GDS_SSO_MOCK_INVALID"]

  def login_as(user)
    ENV["GDS_SSO_MOCK_INVALID"] = @cached_gds_sso_mock_invalid

    GDS::SSO.test_user = user
  end

  def logout
    # If GDS_SSO_MOCK_INVALID is not present the gds-sso mock strategy will get
    # the first user from the database when authenticate! is called
    ENV["GDS_SSO_MOCK_INVALID"] = "true"

    GDS::SSO.test_user = nil
  end

  def super_admin_user
    @super_admin_user ||= FactoryBot.create(:user, role: :super_admin)
  end

  def editor_user
    @editor_user ||= FactoryBot.create(:user, role: :editor)
  end

  def trial_user
    @trial_user ||= FactoryBot.create(:user, role: :trial)
  end

  def login_as_super_admin_user
    login_as super_admin_user
  end

  def login_as_editor_user
    login_as editor_user
  end

  def login_as_trial_user
    login_as trial_user
  end
end

RSpec.configure do |config|
  config.include AuthenticationFeatureHelpers, type: :feature
  config.include AuthenticationFeatureHelpers, type: :request

  config.after(:example, type: :feature) do
    logout
  end
  config.after(:example, type: :request) do
    logout
  end
end
