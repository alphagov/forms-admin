require "rails_helper"

feature "Manage members of group", type: :feature do
  let(:organisation) { standard_user.organisation }
  let(:group) { create(:group, name: "Group 1", organisation:) }
  let(:existing_editor) { create(:user, organisation:) }
  let(:existing_group_admin) { create(:user, organisation:) }
  let(:new_user) { create(:user, organisation:) }

  before do
    create(:membership, user: standard_user, group:, role: :group_admin)
    create(:membership, user: existing_editor, group:, role: :editor)
    create(:membership, user: existing_group_admin, group:, role: :group_admin)
  end

  scenario "group admin adds a new editor" do
    login_as_standard_user
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

    expect(page).to have_table(with_rows: [[existing_editor.name, existing_editor.email], [existing_group_admin.name, existing_group_admin.email]])

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
    fill_in "Enter the email address of the person you want to add", with: new_user.email
    click_button "Add this person"
  end

  def when_i_fill_in_the_add_group_admin_form
    fill_in "Enter the email address of the person you want to add", with: new_user.email
    choose("Group admin")
    click_button "Add this person"
  end

  def then_i_should_see_the_new_group_admin
    expect(page.find("h1")).to have_text "Group 1"

    expect(page).to have_table(with_rows: [[new_user.email, "Group admin"]])
  end

  def then_i_should_see_the_user_as_editor
    expect(page.find("h1")).to have_text "Group 1"

    expect(page).to have_table(with_rows: [[new_user.email, "Editor"]])
  end

  def when_i_click_make_editor_for_user
    within(:table_row, [new_user.email]) do
      click_button "Make editor"
    end
  end
end
