require "rails_helper"

feature "Make changes live", type: :feature do
  let(:form) { build :form, :live, :with_active_resource, id: 1, name: "Apply for a juggling license" }
  let(:org_forms) { [form] }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end
  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?organisation_id=1", req_headers, org_forms.to_json, 200
      mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      mock.get "/api/v1/forms/1/live", req_headers, form.to_json(include: [:pages]), 200
      mock.post "/api/v1/forms/1/make-live", post_headers, form.to_json(include: [:pages]), 200
    end

    login_as_editor_user
  end

  scenario "Form creator makes changes after making form live" do
    visit root_path
    expect(page.find("h1")).to have_text "GOV.UK Forms"
    expect_page_to_have_no_axe_errors(page)

    click_link form.name
    expect(page.find("h1")).to have_text form.name
    expect(page).to have_css ".govuk-tag.govuk-tag--turquoise", text: "Live"
    expect_page_to_have_no_axe_errors(page)

    click_link_or_button "Create a draft to edit"
    expect(page.find("h1")).to have_text "Edit your form"
    expect(page.find("h1")).to have_text form.name
    expect(page).to have_css ".govuk-tag.govuk-tag--yellow", text: "Draft"
    expect_page_to_have_no_axe_errors(page)

    click_link "Make your changes live"
    expect(page.find("h1")).to have_text "Make your changes live"
    expect(page.find("h1")).to have_text form.name
    expect(page).to have_text "Are you sure you want to make your draft live?"
    expect_page_to_have_no_axe_errors(page)

    choose "Yes"
    click_button "Save and continue"
    expect(page.find("h1")).to have_text "Your changes are live"
    expect_page_to_have_no_axe_errors(page)
  end
end
