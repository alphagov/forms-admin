require "rails_helper"

feature "View groups", type: :feature do
  let!(:org_group) { create :group, organisation: super_admin_user.organisation, name: "Group 1" }
  let!(:other_org) { create :organisation, slug: "other-org" }
  let!(:other_org_group) { create :group, organisation: other_org, name: "Group 2" }

  let(:other_org_user) { create :user, organisation: other_org }

  before do
    # Organisations only show in the autocomplete if they have at least one user
    other_org_user
  end

  scenario "Super admin can use autocomplete to view other organisation's forms" do
    given_i_am_logged_in_as_a_super_admin
    and_i_am_on_the_groups_page
    then_i_should_see_the_groups_for_my_organisation
    when_i_change_the_organisation
    then_i_should_see_the_groups_for_that_organisation
  end

  def given_i_am_logged_in_as_a_super_admin
    login_as_super_admin_user
  end

  def and_i_am_on_the_groups_page
    visit groups_path
  end

  def then_i_should_see_the_groups_for_my_organisation
    expect(page).to have_css("h2", text: "You’re viewing #{super_admin_user.organisation.name} groups")
    expect(page).to have_content(org_group.name)
    expect(page).not_to have_content(other_org_group.name)
  end

  def when_i_change_the_organisation
    fill_in "search-organisation-id-field", with: other_org.name.to_s
    page.send_keys :enter
    click_button "Change"
  end

  def then_i_should_see_the_groups_for_that_organisation
    expect(page).to have_css("h2", text: "You’re viewing #{other_org.name} groups")
    expect(page).to have_content(other_org_group.name)
    expect(page).not_to have_content(org_group.name)
  end
end
