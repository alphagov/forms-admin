require "rails_helper"

feature "Create a new group", type: :feature, feature_groups: true do
  before do
    login_as_editor_user
  end

  scenario "Form creator creates a new group" do
    when_i_visit_the_groups_page
    and_i_click_create_a_group
    and_i_fill_in_the_group_name
    then_i_should_see_the_new_group
    and_i_use_the_back_link
    then_i_should_see_the_new_group_on_the_groups_page
  end

  def when_i_visit_the_groups_page
    visit groups_path
    expect(page.find("h1")).to have_text "Your groups"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_click_create_a_group
    click_link "Create a group"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_fill_in_the_group_name
    fill_in "Name", with: "Group 1"
    click_button "Save"
  end

  def then_i_should_see_the_new_group
    expect(page.find("h1")).to have_text "Group 1"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_use_the_back_link
    click_link "Back to your groups"
  end

  def then_i_should_see_the_new_group_on_the_groups_page
    expect(page).to have_link "Group 1"
  end
end
