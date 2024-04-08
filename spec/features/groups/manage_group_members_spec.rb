require "rails_helper"

feature "Show members of a group", type: :feature do
  let(:organisation) { editor_user.organisation }
  let(:group) { create(:group, name: "Group 1", organisation:) }
  let(:user1) { create(:user, organisation:) }
  let(:user2) { create(:user, organisation:) }

  before do
    create(:membership, user: editor_user, group:, role: :editor)
    create(:membership, user: user1, group:, role: :editor)
    create(:membership, user: user2, group:, role: :group_admin)
    login_as_editor_user
  end

  scenario "Group editor lists members of a group" do
    when_i_visit_the_groups_page
    and_i_click_the_group_link
    and_i_click_the_edit_group_members_link
    then_i_should_see_the_members_of_the_group
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
end
