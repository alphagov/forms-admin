require "rails_helper"

feature "Make changes live", type: :feature do
  let(:form) { build :form, :live, :with_active_resource, id: 1, name: "Apply for a juggling license" }
  let(:org_forms) { [form] }
  let(:pages) { build_list :page, 5, form_id: form.id }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?organisation_id=1", headers, org_forms.to_json, 200
      mock.get "/api/v1/forms/1", headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      mock.get "/api/v1/forms/1/live", headers, form.to_json(include: [:pages]), 200
      mock.post "/api/v1/forms/1/make-live", post_headers, form.to_json(include: [:pages]), 200
    end

    login_as_editor_user
  end

  scenario "Form creator makes changes after making form live" do
    given_i_am_viewing_a_live_form
    when_i_click_create_a_draft
    then_i_see_the_page_to_edit_the_draft
    when_i_click_make_your_changes_live
    then_i_see_a_page_to_confirm_making_the_draft_live
    when_i_choose_yes
    then_i_see_a_confirmation_that_the_changes_are_live
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

  def when_i_click_make_your_changes_live
    click_link "Make your changes live"
  end

  def then_i_see_a_page_to_confirm_making_the_draft_live
    expect(page.find("h1")).to have_text "Make your changes live"
    expect(page.find("h1")).to have_text form.name
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
end
