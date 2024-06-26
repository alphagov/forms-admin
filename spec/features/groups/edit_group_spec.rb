require "rails_helper"

feature "Create a new group", type: :feature do
  before do
    login_as_editor_user
  end

  describe "changing the name of an existing group" do
    let(:group) { create(:group, organisation: editor_user.organisation, creator: editor_user) }

    before do
      create(:membership, user: editor_user, group:, role: :group_admin)
    end

    scenario "group admin can change the name of a group" do # rubocop:disable RSpec/NoExpectationExample
      when_i_visit_the_group_page
      and_i_click_change_name
      then_i_see_the_change_name_page
      and_i_enter_a_new_name
      then_i_should_see_the_group_with_new_name
    end
  end

  def when_i_visit_the_group_page
    visit group_path(group)
  end

  def and_i_click_change_name
    click_link "Change the name of this group"
  end

  def then_i_see_the_change_name_page
    expect(page.find("h1")).to have_text "Change the name of this group"
  end

  def and_i_enter_a_new_name
    fill_in "Change the name of this group", with: "new group name"
    click_button "Save and continue"
  end

  def then_i_should_see_the_group_with_new_name
    expect(page.find("h1")).to have_text "new group name"
  end
end
