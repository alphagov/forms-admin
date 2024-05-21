require "rails_helper"

feature "Archive a form", type: :feature do
  let(:form) { build(:form, :live, id: 1) }
  let(:org_forms) { [form] }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?organisation_id=1", headers, org_forms.to_json, 200
      mock.get "/api/v1/forms/1", headers, form.to_json, 200
      mock.get "/api/v1/forms/1/live", headers, form.to_json, 200
      mock.get "/api/v1/forms/1/archived", headers, form.to_json, 200
      mock.post "/api/v1/forms/1/archive", post_headers, {}, 200
    end

    login_as_editor_user
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
