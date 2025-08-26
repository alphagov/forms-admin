require "rails_helper"

feature "Add user research contact preference", type: :feature do
  let(:user) { create(:user, name: "Test name", research_contact_status: "to_be_asked") }

  before do
    login_as user
  end

  describe "user adds their user research content preference" do
    scenario "user can update their preference" do
      when_i_visit_the_edit_page
      when_i_choose_yes
      then_i_should_be_redirecteed_to_the_groups_page
    end
  end

  def when_i_visit_the_edit_page
    visit edit_account_contact_for_research_path
  end

  def when_i_choose_yes
    choose "Yes"
    click_button "Continue"
  end

  def then_i_should_be_redirecteed_to_the_groups_page
    expect(page.find("h1")).to have_text "Your groups"
  end
end
