require "rails_helper"

feature "Request an upgrade for a group", type: :feature, feature_groups: true do
  let!(:group) do
    create(:group, organisation: editor_user.organisation).tap do |group|
      create(:membership, user: editor_user, group:, role: :group_admin)
    end
  end

  scenario "a group admin requests an upgrade that is approved by an admin user" do
    given_i_am_logged_in_as_a_group_admin
    and_i_visit_the_groups_page
    and_i_click_on_the_group
    when_i_click_on_the_link_to_request_to_upgrade_the_group
    then_i_see_a_page_to_confirm_the_request
    when_i_click_the_button_to_send_the_request
    then_i_see_a_confirmation_that_the_request_has_been_sent

    given_i_am_logged_in_as_an_organisation_admin
    and_i_visit_the_groups_page
    then_i_see_a_notification_banner_stating_there_are_upgrade_requests
    and_i_click_on_the_group
    then_i_see_a_notification_banner_for_the_upgrade_request
    when_i_click_the_link_to_accept_or_reject_the_request
    then_i_see_a_page_to_accept_or_reject_the_request
    when_i_choose_yes
    then_i_see_a_success_message
    and_the_group_is_now_active
  end

  def given_i_am_logged_in_as_a_group_admin
    login_as_editor_user
  end

  def and_i_visit_the_groups_page
    visit groups_path
    expect(page.find("h1")).to have_text "Your groups"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_click_on_the_group
    click_link group.name
    expect(page.find("h1")).to have_text group.name
    expect(page).to have_css ".govuk-caption-l", text: "Trial group"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_click_on_the_link_to_request_to_upgrade_the_group
    click_link "Find out how to upgrade this group so you can make forms live"
  end

  def then_i_see_a_page_to_confirm_the_request
    expect(page.find("h1")).to have_text "Request to upgrade this trial group"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_click_the_button_to_send_the_request
    click_link_or_button "Send request to upgrade"
  end

  def then_i_see_a_confirmation_that_the_request_has_been_sent
    expect(page.find("h1")).to have_text "Your upgrade request has been sent"
    expect_page_to_have_no_axe_errors(page)
  end

  def given_i_am_logged_in_as_an_organisation_admin
    login_as_organisation_admin_user
  end

  def then_i_see_a_notification_banner_stating_there_are_upgrade_requests
    expect(page).to have_css ".govuk-notification-banner", text: "You have one request to upgrade a trial group."
    expect_page_to_have_no_axe_errors(page)
  end

  def then_i_see_a_notification_banner_for_the_upgrade_request
    expect(page.find("h3")).to have_text "A group admin has asked to upgrade this group"
    expect(page).to have_css ".govuk-notification-banner", text: "#{editor_user.name} has asked to upgrade this group so they can make forms live."
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_click_the_link_to_accept_or_reject_the_request
    click_link "Accept or reject this upgrade request"
  end

  def then_i_see_a_page_to_accept_or_reject_the_request
    expect(page).to have_text "#{editor_user.name} has asked to upgrade this group to an ‘active’ group."
    expect(page.find("h1")).to have_text "Upgrade this group"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_choose_yes
    choose "Yes"
    click_button "Save and continue"
  end

  def then_i_see_a_success_message
    expect(page).to have_css ".govuk-notification-banner--success", text: "This group is now active"
  end

  def and_the_group_is_now_active
    expect(page).to have_css ".govuk-caption-l", text: "Active group"
    expect_page_to_have_no_axe_errors(page)
  end
end
