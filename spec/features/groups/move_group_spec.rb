require "rails_helper"

feature "Move a group", type: :feature do
  before do
    login_as_super_admin_user
  end

  describe "changing the name of an existing group" do
    let(:group) { create(:group, organisation: super_admin_user.organisation, creator: super_admin_user) }

    before do
      create(:membership, user: super_admin_user, group:, role: :group_admin)
    end

    scenario "group admin can change the name of a group" do
      when_i_visit_the_group_page
      and_i_click_move_group
      then_i_see_the_move_group_page
    end
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
end
