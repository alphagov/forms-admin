require "rails_helper"

feature "Record time when user last signed in" do
  let(:user) { create :user, last_signed_in_at: nil }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:auth0] = Faker::Omniauth.auth0(
      uid: user.uid,
      email: user.email,
    )

    allow(Settings).to receive(:auth_provider).and_return("auth0")

    freeze_time
  end

  after do
    unfreeze_time

    OmniAuth.config.mock_auth[:auth0] = nil
    OmniAuth.config.test_mode = false
  end

  scenario "user authenticates" do
    when_i_sign_in
    then_my_last_signed_in_at_time_is_updated
  end

private

  def when_i_sign_in
    visit root_path
  end

  def then_my_last_signed_in_at_time_is_updated
    user.reload
    expect(user.last_signed_in_at).to eq Time.zone.now
  end
end
