require "rails_helper"

describe "Login to the service", type: :feature do
  let(:user) { create :user, :with_trial_role, name: "Test User", email: "test@example.gov.uk" }
  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?creator_id=#{user.id}", req_headers, [].to_json, 200
    end
    allow(Settings).to receive(:auth_provider).and_return("developer")
  end

  it "an unauthenticated user gets redirected through the auth journey" do
    when_i_visit_the_homepage
    then_i_am_redirected_to_the_developer_login_page
    when_i_enter_an_email_address_and_click_login
    then_i_am_redirected_to_the_user_identification_page
  end

private

  def when_i_visit_the_homepage
    visit root_path
  end

  def then_i_am_redirected_to_the_developer_login_page
    expect(page).to have_field "Email"
    expect(page).to have_button "Sign In"
  end

  def when_i_enter_an_email_address_and_click_login
    fill_in "Email", with: user.email
    click_on "Sign In"
  end

  def then_i_am_redirected_to_the_user_identification_page
    expect(page).to have_current_path(edit_user_identification_path)
  end
end
