require "rails_helper"

feature "Copy a form", type: :feature do
  let(:original_form) { create(:form, :with_pages, name: "Apply for a juggling license") }
  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    GroupForm.create! group:, form_id: original_form.id
    create(:membership, group:, user: standard_user, added_by: standard_user)

    login_as standard_user
  end

  scenario "as a form editor copying a draft form" do
    given_i_am_viewing_a_draft_form
    when_i_click_make_a_copy_of_this_form
    then_i_am_shown_the_copy_form_page
    when_i_enter_a_new_name_for_the_copied_form
    then_the_form_is_copied_with_the_new_name
    and_i_am_redirected_to_the_copied_form
  end

  scenario "copying a draft form with default name" do
    given_i_am_viewing_a_draft_form
    when_i_click_make_a_copy_of_this_form
    then_i_am_shown_the_copy_form_page
    when_i_keep_the_default_name
    then_the_form_is_copied_with_copy_of_prefix
    and_i_am_redirected_to_the_copied_form
  end

  scenario "validation error when name is blank" do
    given_i_am_viewing_a_draft_form
    when_i_click_make_a_copy_of_this_form
    then_i_am_shown_the_copy_form_page
    when_i_submit_with_blank_name
    then_i_see_a_validation_error
  end

  def given_i_am_viewing_a_draft_form
    visit form_path(original_form.id)
    expect(page.find("h1")).to have_text original_form.name
    expect(page).to have_css ".govuk-tag.govuk-tag--yellow", text: "Draft"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_click_make_a_copy_of_this_form
    click_link_or_button "Make a copy of this form"
  end

  def then_i_am_shown_the_copy_form_page
    expect(page.find("h1")).to have_text "What is the name of your form?"
    expect(page).to have_field("What is the name of your form?", with: "Copy of #{original_form.name}")
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_enter_a_new_name_for_the_copied_form
    fill_in "What is the name of your form?", with: "My copied juggling license form"
    click_button "Save and continue"
  end

  def when_i_keep_the_default_name
    click_button "Save and continue"
  end

  def then_the_form_is_copied_with_the_new_name
    expect(page).to have_css ".govuk-notification-banner--success", text: "Your form has been copied"
    expect(page).to have_text("My copied juggling license form")
  end

  def then_the_form_is_copied_with_copy_of_prefix
    expect(page).to have_css ".govuk-notification-banner--success", text: "Your form has been copied"
    expect(page).to have_text("Copy of #{original_form.name}")
  end

  def and_i_am_redirected_to_the_copied_form
    expect(page.find("h1")).to have_text(/Create a form|Edit a form/)
    expect(page).to have_css ".govuk-tag.govuk-tag--yellow", text: "Draft"
    expect_page_to_have_no_axe_errors(page)

    # Verify we're on a different form by checking the URL
    expect(page).to have_no_current_path(form_path(original_form.id), ignore_query: true)
    expect(page).to have_current_path(/\/forms\/\d+/)
  end

  def when_i_submit_with_blank_name
    fill_in "What is the name of your form?", with: ""
    click_button "Save and continue"
  end

  def then_i_see_a_validation_error
    expect(page).to have_css ".govuk-error-summary"
    expect(page).to have_content "Enter a name for the form"
    expect_page_to_have_no_axe_errors(page)
  end
end
