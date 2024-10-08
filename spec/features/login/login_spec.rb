require "rails_helper"

describe "Login to the service", type: :feature do
  let(:user) { standard_user }

  before do
    allow(Settings).to receive(:auth_provider).and_return("developer")
  end

  scenario "an unauthenticated user gets redirected through the auth journey" do
    when_i_visit_the_homepage
    then_i_am_redirected_to_the_developer_login_page
    when_i_enter_an_email_address_and_click_login
    then_i_am_redirected_back_to_the_groups_page
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

  def then_i_am_redirected_back_to_the_homepage
    expect(page).to have_current_path(root_path)
  end

  def then_i_am_redirected_back_to_the_groups_page
    expect(page).to have_current_path(root_path)
  end
end
