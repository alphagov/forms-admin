require "rails_helper"

feature "Make changes live", type: :feature do
  let(:form) { create :form, :live, name: "Apply for a juggling license" }
  let(:pages) { build_list :page, 5, form_id: form.id }
  let(:organisation) { build :organisation, id: 1 }
  let(:user) { create :user, organisation: }
  let(:group) { create(:group, name: "Group 1", organisation:, status: "active") }
  let(:updated_name) { "Another form of juggling" }

  before do
    GroupForm.create!(form_id: form.id, group_id: group.id)
    Membership.create!(user:, group:, added_by: user, role: :group_admin)

    ActiveResource::HttpMock.respond_to do |mock|
      mock.put "/api/v1/forms/#{form.id}", post_headers, {}, 200
      mock.post "/api/v1/forms/#{form.id}/make-live", post_headers, {}, 200
    end

    login_as user
  end

  scenario "Form creator makes changes after making form live" do
    given_i_am_viewing_a_live_form
    when_i_click_create_a_draft
    then_i_see_the_page_to_edit_the_draft
    then_i_edit_the_name_of_the_form
    then_i_mark_the_share_preview_step_as_completed
    when_i_click_make_your_changes_live
    then_i_see_a_page_to_confirm_making_the_draft_live
    when_i_choose_yes
    then_i_see_a_confirmation_that_the_changes_are_live
  end
end

def given_i_am_viewing_a_live_form
  visit live_form_path(form.id)
  expect(page.find("h1")).to have_text form.name
  expect(page).to have_css ".govuk-tag.govuk-tag--turquoise", text: "Live"
  expect_page_to_have_no_axe_errors(page)
end

def when_i_click_create_a_draft
  click_link_or_button "Create a draft to edit"
end

def then_i_see_the_page_to_edit_the_draft
  expect(page.find("h1")).to have_text "Edit your form"
  expect(page.find("h1")).to have_text form.name
  expect(page).to have_css ".govuk-tag.govuk-tag--yellow", text: "Draft"
  expect_page_to_have_no_axe_errors(page)
end

def then_i_edit_the_name_of_the_form
  click_link "Edit the name of your form"
  fill_in "What’s the name of your form?", with: updated_name
  click_button "Save and continue"
end

def then_i_mark_the_share_preview_step_as_completed
  click_link_or_button "Share a preview of your draft form"
  choose "Yes"
  click_link_or_button "Save and continue"
end

def when_i_click_make_your_changes_live
  click_link "Make your changes live"
end

def then_i_see_a_page_to_confirm_making_the_draft_live
  expect(page.find("h1")).to have_text "Make your changes live"
  expect(page.find("h1")).to have_text updated_name
  expect(page).to have_text "Are you sure you want to make your draft live?"
  expect_page_to_have_no_axe_errors(page)
end

def when_i_choose_yes
  choose "Yes"
  click_button "Save and continue"
end

def then_i_see_a_confirmation_that_the_changes_are_live
  expect(page.find("h1")).to have_text "Your changes are live"
  expect_page_to_have_no_axe_errors(page)
end
