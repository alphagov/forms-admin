require "warden"

module AuthenticationFeatureHelpers
  include Warden::Test::Helpers

  @cached_gds_sso_mock_invalid = ENV["GDS_SSO_MOCK_INVALID"]

  def login_as(user, opts = {})
    if %i[gds_sso mock_gds_sso].include? Settings.auth_provider.to_sym
      ENV["GDS_SSO_MOCK_INVALID"] = @cached_gds_sso_mock_invalid
      GDS::SSO.test_user = user
    else
      opts[:run_callbacks] ||= false # Callbacks are from gds-sso gem
    end

    super user, opts
  end

  def logout
    if %i[gds_sso mock_gds_sso].include? Settings.auth_provider.to_sym
      # If GDS_SSO_MOCK_INVALID is not present the gds-sso mock strategy will get
      # the first user from the database when authenticate! is called
      ENV["GDS_SSO_MOCK_INVALID"] = "true"

      GDS::SSO.test_user = nil
    end

    super
  end

  def test_org
    @test_org ||= FactoryBot.create(:organisation, id: 1, slug: "test-org")
  end

  def super_admin_user
    @super_admin_user ||= FactoryBot.create(:super_admin_user, organisation: test_org)
  end

  def editor_user
    @editor_user ||= FactoryBot.create(:editor_user, organisation: test_org)
  end

  def trial_user
    @trial_user ||= FactoryBot.create(:user, :with_trial_role)
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

  config.before(:example, type: :feature) do
    Warden.test_mode!
  end
  config.before(:example, type: :request) do
    Warden.test_mode!
  end

  config.after(:example, type: :feature) do
    Warden.test_reset!
  end
  config.after(:example, type: :request) do
    Warden.test_reset!
  end
end
