require "rails_helper"

feature "Request an upgrade for a group", type: :feature do
  let!(:group) do
    create(:group, organisation: editor_user.organisation).tap do |group|
      create(:membership, user: editor_user, group:, role: :group_admin)
    end
  end

  scenario "a group admin requests an upgrade that is approved by an admin user" do
    login_as_editor_user

    visit groups_path
    expect(page.find("h1")).to have_text "Your groups"
    expect_page_to_have_no_axe_errors(page)

    click_link group.name
    expect(page.find("h1")).to have_text group.name
    expect(page).to have_css ".govuk-caption-l", text: "Trial group"
    expect_page_to_have_no_axe_errors(page)

    click_link "Find out how to upgrade this group so you can make forms live"
    expect(page.find("h1")).to have_text "Request to upgrade this trial group"
    expect_page_to_have_no_axe_errors(page)

    click_link_or_button "Send request to upgrade"
    expect(page.find("h1")).to have_text "Your upgrade request has been sent"
    expect_page_to_have_no_axe_errors(page)

    login_as_organisation_admin_user

    visit groups_path
    expect(page).to have_css ".govuk-notification-banner", text: "You have one request to upgrade a trial group."
    expect_page_to_have_no_axe_errors(page)

    click_link group.name
    expect(page.find("h3")).to have_text "A group admin has asked to upgrade this group"
    expect(page).to have_css ".govuk-notification-banner", text: "#{editor_user.name} has asked to upgrade this group so they can make forms live."
    expect_page_to_have_no_axe_errors(page)

    click_link "Accept or reject this upgrade request"
    expect(page).to have_text "#{editor_user.name} has asked to upgrade this group to an ‘active’ group."
    expect(page.find("h1")).to have_text "Upgrade this group"
    expect_page_to_have_no_axe_errors(page)

    choose "Yes"
    click_button "Save and continue"
    expect(page).to have_css ".govuk-notification-banner--success", text: "This group is now active"
    expect(page).to have_css ".govuk-caption-l", text: "Active group"
    expect_page_to_have_no_axe_errors(page)
  end
end
