require "rails_helper"

describe "Sign an MOU for my organisation", type: :feature do
  it "a logged in user can sign an MOU" do # rubocop:disable RSpec/NoExpectationExample
    login_as_trial_user
    when_i_visit_the_mou_page
    then_i_agree_and_submit_the_mou
    then_i_can_see_the_mou_confirmation_page
  end

private

  def when_i_visit_the_mou_page
    visit mou_signature_path
  end

  def then_i_agree_and_submit_the_mou
    check "I agree to the MOU on behalf of my organisation"
    click_button "Save and continue"
  end

  def then_i_can_see_the_mou_confirmation_page
    expect(page).to have_text "You've agreed to the MOU"
  end
end
