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
    visit root_path
    expect(page.find("h1")).to have_text "GOV.UK Forms"
    expect_page_to_have_no_axe_errors(page)

    click_link form.name
    expect(page.find("h1")).to have_text form.name
    expect(page).to have_css ".govuk-tag.govuk-tag--turquoise", text: "Live"
    expect_page_to_have_no_axe_errors(page)

    click_link_or_button "Archive this form"
    expect(page.find("h1")).to have_text "Archive this form"
    expect(page).to have_text "Are you sure you want to archive this form?"
    expect_page_to_have_no_axe_errors(page)

    choose "Yes"
    click_button "Save and continue"
    expect(page.find("h1")).to have_text "Your form has been archived"
    expect_page_to_have_no_axe_errors(page)

    click_link_or_button "Continue to form details"
    expect(page.find("h1")).to have_text form.name
    expect(page).to have_css ".govuk-tag.govuk-tag--orange", text: "Archived"
    expect_page_to_have_no_axe_errors(page)
  end
end
