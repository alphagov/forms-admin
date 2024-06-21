require "rails_helper"

feature "Manage members of group", type: :feature do
  let(:organisation) { editor_user.organisation }
  let(:group) { create(:group, name: "Group 1", organisation:) }
  let(:user1) { create(:user, organisation:) }
  let(:user2) { create(:user, organisation:) }
  let(:user3) { create(:user, organisation:) }

  before do
    create(:membership, user: editor_user, group:, role: :group_admin)
    create(:membership, user: user1, group:, role: :editor)
    create(:membership, user: user2, group:, role: :group_admin)
  end

  scenario "group admin adds a new editor" do
    login_as_editor_user
    when_i_visit_the_groups_page
    and_i_click_the_group_link
    and_i_click_the_edit_group_members_link
    then_i_should_see_the_members_of_the_group
    when_i_click_add_editor
    then_i_should_see_the_add_editor_form
    when_i_fill_in_the_add_editor_form
    then_i_should_see_the_user_as_editor
  end

  scenario "organisation admin adds a new group_admin and changes them to editor" do
    login_as_organisation_admin_user
    when_i_visit_the_groups_page
    and_i_click_the_group_link
    and_i_click_the_edit_group_members_link
    then_i_should_see_the_members_of_the_group
    when_i_click_add_editor_or_group_admin
    then_i_should_see_the_add_editor_or_group_admin_form
    when_i_fill_in_the_add_group_admin_form
    then_i_should_see_the_new_group_admin
    when_i_click_make_editor_for_user
    then_i_should_see_the_user_as_editor
  end

  def when_i_visit_the_groups_page
    visit groups_path
  end

  def and_i_click_the_group_link
    click_link "Group 1"
  end

  def and_i_click_the_edit_group_members_link
    click_link "Edit members of this group"
  end

  def then_i_should_see_the_members_of_the_group
    expect(page.find("h1")).to have_text "Group 1"
    expect(page).to have_text user1.name
    expect(page).to have_text user1.email
    expect(page).to have_text user2.name
    expect(page).to have_text user2.email
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_click_add_editor
    click_link "Add an editor"
  end

  def when_i_click_add_editor_or_group_admin
    click_link "Add an editor or group admin"
  end

  def then_i_should_see_the_add_editor_form
    expect(page.find("h1")).to have_text "Add an editor to this group"
    expect_page_to_have_no_axe_errors(page)
  end

  def then_i_should_see_the_add_editor_or_group_admin_form
    expect(page.find("h1")).to have_text "Add an editor or group admin to this group"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_fill_in_the_add_editor_form
    fill_in "Enter the email address of the person you want to add", with: user3.email
    click_button "Add this person"
  end

  def when_i_fill_in_the_add_group_admin_form
    fill_in "Enter the email address of the person you want to add", with: user3.email
    choose("Group admin")
    click_button "Add this person"
  end

  def then_i_should_see_the_new_group_admin
    expect(page.find("h1")).to have_text "Group 1"

    user_row = page.find("td", text: user3.name).ancestor("tr")
    within(user_row) do
      expect(user_row).to have_text user3.name
      expect(user_row).to have_text user3.email
      expect(user_row).to have_text "Group admin"
    end
  end

  def then_i_should_see_the_user_as_editor
    expect(page.find("h1")).to have_text "Group 1"

    user_row = page.find("td", text: user3.name).ancestor("tr")
    within(user_row) do
      expect(user_row).to have_text user3.name
      expect(user_row).to have_text user3.email
      expect(user_row).to have_text "Editor"
    end
  end

  def when_i_click_make_editor_for_user
    user_row = page.find("td", text: user3.name).ancestor("tr")
    user_row.click_button "Make editor"
  end
end
