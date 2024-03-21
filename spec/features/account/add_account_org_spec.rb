require "rails_helper"

feature "Add account organisation to user without organisation", type: :feature do
  let(:user) { create :user, :with_no_org }
  let!(:organisation) { create :organisation }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?creator_id=#{user.id}", headers, [].to_json, 200
    end
    login_as user
  end

  scenario "when the user does not have an organisation" do
    when_i_visit_the_account_organisation_page
    and_i_select_an_organisation
    then_i_should_be_redirected_to_the_root_path
  end

private

  def when_i_visit_the_account_organisation_page
    visit edit_account_organisation_path
    expect(page).to have_content("Select your organisation")
  end

  def and_i_select_an_organisation
    fill_in "Select your organisation", with: "#{organisation.name}\n"
    click_button "Save and continue"
  end

  def then_i_should_be_redirected_to_the_root_path
    expect(page).to have_current_path(root_path)
  end
end
