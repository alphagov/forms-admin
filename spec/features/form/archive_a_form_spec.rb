require "rails_helper"

feature "Archive a form", type: :feature do
  let(:form) { create(:form, :live) }
  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    GroupForm.create! group:, form_id: form.id
    create(:membership, group:, user: standard_user, added_by: standard_user)

    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/api/v1/forms/#{form.id}/archive", post_headers, {}, 200
    end

    login_as standard_user
  end

  scenario "as a form editor" do
    given_i_am_viewing_a_live_form
    when_i_click_archive_this_form
    then_i_am_shown_the_archive_form_page
    when_i_choose_yes
    then_i_am_shown_a_page_confirming_the_form_has_been_archived
    when_i_continue_to_form_details
    then_the_form_has_the_archived_tag
  end

  def given_i_am_viewing_a_live_form
    visit live_form_path(form.id)
    expect(page.find("h1")).to have_text form.name
    expect(page).to have_css ".govuk-tag.govuk-tag--turquoise", text: "Live"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_click_archive_this_form
    click_link_or_button "Archive this form"
  end

  def then_i_am_shown_the_archive_form_page
    expect(page.find("h1")).to have_text "Archive this form"
    expect(page).to have_text "Are you sure you want to archive this form?"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_choose_yes
    choose "Yes"
    click_button "Save and continue"
  end

  def then_i_am_shown_a_page_confirming_the_form_has_been_archived
    expect(page.find("h1")).to have_text "Your form has been archived"
    expect_page_to_have_no_axe_errors(page)
  end

  def when_i_continue_to_form_details
    click_link_or_button "Continue to form details"
    expect(page.find("h1")).to have_text form.name
  end

  def then_the_form_has_the_archived_tag
    expect(page).to have_css ".govuk-tag.govuk-tag--orange", text: "Archived"
    expect_page_to_have_no_axe_errors(page)
  end
end
