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

  scenario "super admin can see when user last signed in" do
    given_a_user_who_has_signed_in_since_last_signed_in_at_added
    when_i_sign_in_as_a_super_admin
    and_i_edit_that_user
    then_i_see_when_that_user_last_signed_in
  end

private

  def when_i_sign_in
    visit root_path
  end

  def then_my_last_signed_in_at_time_is_updated
    user.reload
    expect(user.last_signed_in_at).to eq Time.zone.now
  end

  def given_a_user_who_has_signed_in_since_last_signed_in_at_added
    user.update!(last_signed_in_at: Time.zone.local(2024, 11, 5, 9, 12))
  end

  def when_i_sign_in_as_a_super_admin
    login_as_super_admin_user
    visit root_path
  end

  def and_i_edit_that_user
    click_link "Users"
    click_link user.email

    expect(page).to have_title user.name
  end

  def then_i_see_when_that_user_last_signed_in
    expect(page).to have_text "Last signed in 5 November 2024"
  end
end
