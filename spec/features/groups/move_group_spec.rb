require "rails_helper"

feature "Move a group", type: :feature do
  describe "changing the name of an existing group" do
    let(:group) { create(:group, :active, organisation: super_admin_user.organisation, creator: super_admin_user) }
    let(:other_org) { create :organisation, name: "Other Org", slug: "other-org" }

    before do
      create(:membership, user: super_admin_user, group:, role: :group_admin)
      create :user, organisation: other_org
    end

    scenario "group admin can change the name of a group" do
      given_i_am_logged_in_as_a_super_admin
      and_i_am_on_the_groups_page
      then_i_see_the_group_in_my_organisation
      when_i_visit_the_group_page
      and_i_click_move_group
      then_i_see_the_move_group_page
      when_i_change_the_organisation
      then_i_see_my_new_org_for_this_group
    end
  end

  def given_i_am_logged_in_as_a_super_admin
    login_as_super_admin_user
  end

  def and_i_am_on_the_groups_page
    visit groups_path
  end

  def then_i_see_the_group_in_my_organisation
    expect(page).to have_content(group.name)
  end

  def when_i_visit_the_group_page
    visit group_path(group)
  end

  def and_i_click_move_group
    click_link "Move this group to another organisation"
  end

  def then_i_see_the_move_group_page
    expect(page.find("h1")).to have_text("Move this group to another organisation")
  end

  def when_i_change_the_organisation
    fill_in "group-organisation-id-field", with: other_org.name.to_s
    page.send_keys :enter
    click_button "Save and continue"
  end

  def then_i_see_my_new_org_for_this_group
    expect(page).to have_content("Group's organisation has changed to #{other_org.name}")
  end
end
