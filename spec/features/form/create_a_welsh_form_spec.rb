require "rails_helper"

feature "Create a form with a welsh version", type: :feature do
  let(:group) { create(:group, name: "Welsh enabled", organisation: standard_user.organisation, status: "active", welsh_enabled: true) }

  before do
    GroupForm.create!(group:, form_id: form.id)
    create(:membership, group:, user: standard_user, added_by: standard_user)

    login_as standard_user

    allow(FeatureService).to receive(:enabled?).with(:describe_none_of_the_above_enabled).and_return(true)
  end

  context "when a form has existing pages" do
    let(:form) { create :form, :with_pages }

    scenario "create a Welsh version of the form" do
      when_i_am_viewing_an_existing_form
      and_i_create_a_welsh_version_of_the_form
      then_i_see_a_success_message
      and_i_can_edit_the_welsh_text
    end
  end

private

  def when_i_am_viewing_an_existing_form
    visit form_path(form.id)
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_create_a_welsh_version_of_the_form
    click_on "Add a Welsh version of your form"
    expect(page.find("h1")).to have_text "Add a Welsh version of your form"
    expect_page_to_have_no_axe_errors(page)
    page.find_all("tbody .govuk-table__row").map do |row|
      row.find_all(".govuk-input").map do |input|
        input.fill_in with: Faker::Lorem.question
      end
    end
    fill_in "Enter link to your Welsh privacy information", with: "http://gov.uk/welsh-privacy-information"
    choose "Yes"
    click_button "Save and continue"
  end

  def then_i_see_a_success_message
    expect(page).to have_css ".govuk-notification-banner--success", text: "The Welsh version of your form has been saved and marked as complete"
  end

  def and_i_can_edit_the_welsh_text
    click_on "Add a Welsh version of your form"
    expect(page.find("h1")).to have_text "Add a Welsh version of your form"
    expect_page_to_have_no_axe_errors(page)
    fill_in "Enter your Welsh form name", with: "enw eich ffurf Gymraeg"
    choose "Yes"
    click_button "Save and continue"
    click_on "Add a Welsh version of your form"
    expect(page).to have_field("Enter your Welsh form name", with: "enw eich ffurf Gymraeg")
  end
end
