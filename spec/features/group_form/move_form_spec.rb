require "rails_helper"

feature "Move a form", type: :feature do
  describe "moving a form to another group" do
    let(:group) { create(:group, organisation: organisation_admin_user.organisation) }
    # rubocop:disable RSpec/LetSetup
    let!(:another_group) { create(:group, organisation: organisation_admin_user.organisation) }
    # rubocop:enable RSpec/LetSetup
    let(:form) { build :form, id: 1, name: "Bye bye form", created_at: "2024-10-08T07:31:15.762Z" }

    before do
      create(:membership, user: organisation_admin_user, group:, role: :group_admin)
      create(:form_record, id: form.id, name: form.name, created_at: form.created_at)

      allow(FormRepository).to receive(:find).and_return(form)

      group.group_forms.create!(form_id: form.id)
      group.organisation = organisation_admin_user.organisation
      group.save!
    end

    scenario "organisation admin can move a form to another group" do
      given_i_am_logged_in_as_an_organisation_admin
      and_i_am_on_the_group_page
      then_i_see_the_form_in_my_group
      and_i_click_move_form
      then_i_see_the_move_form_page
      when_i_change_the_group
      then_i_see_the_form_is_gone_from_my_group
      and_the_other_group_has_the_form
    end
  end

  def given_i_am_logged_in_as_an_organisation_admin
    login_as_organisation_admin_user
  end

  def and_i_am_on_the_group_page
    visit group_path(group)
  end

  def then_i_see_the_form_in_my_group
    expect(page).to have_content(form.name)
  end

  def and_i_click_move_form
    # TODO: Implement the actual link to move the form, and delete the visit line below
    # click_link "Move this form to another group"
    visit edit_group_form_path(group, id: form.id)
  end

  def then_i_see_the_move_form_page
    # expect(page.find("h1")).to have_text("Move this form to another group")
    # expect(page).to have_field("group-form-group-id-field", with: group.name)
    expect(page).to have_content(another_group.name)
  end

  def when_i_change_the_group
    choose(another_group.name)
    click_button "Continue"
  end

  def then_i_see_the_form_is_gone_from_my_group
    # expect(page).to have_content("Form has been moved to #{another_group.name}")
    expect(page).to have_css("h1", text: group.name)
    expect(page).not_to have_content(form.name)
  end

  def and_the_other_group_has_the_form
    another_group.reload
    visit group_path(another_group)

    expect(page).to have_content(form.name)
  end
end
