require "rails_helper"

feature "Create or edit a form", type: :feature do
  let(:form) { build :form, :with_active_resource, id: 1, name: "Apply for a juggling license" }
  let(:org_forms) { [] }

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
    login_as_editor_user
  end

  context "when creating a form" do
    let(:pages) { [] }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?organisation_id=1", req_headers, org_forms.to_json, 200
        mock.post "/api/v1/forms", post_headers, { id: 1 }.to_json
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end
    end

    scenario "As a form creator" do
      when_i_am_viewing_home_page
      and_i_click_create_a_form
      and_i_fill_in_the_form_name
      then_i_should_have_a_draft_form
    end
  end

  context "when editing an existing form" do
    let(:org_forms) { [form] }
    let(:pages) { build_list :page, 5, form_id: form.id }
    let(:updated_form) do
      updated_form = form
      updated_form.name = "Another form of juggling"
      updated_form
    end

    before do
      form.name = "Another form of juggling"

      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?organisation_id=1", req_headers, org_forms.to_json, 200
        mock.put "/api/v1/forms/1", post_headers
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1", req_headers, updated_form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end
    end

    scenario "As a form creator" do
      when_i_am_viewing_home_page
      and_i_view_an_existing_form
      then_i_edit_the_name_of_the_form
      and_the_form_name_is_updated
    end
  end

private

  def when_i_am_viewing_home_page
    visit root_path
    expect(page.find("h1")).to have_text "GOV.UK Forms"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_click_create_a_form
    click_link "Create a form"
  end

  def and_i_fill_in_the_form_name
    expect_page_to_have_no_axe_errors(page)
    fill_in "What’s the name of your form?", with: form.name
    click_button "Save and continue"
  end

  def then_i_should_have_a_draft_form
    expect(page.find("h1")).to have_text "Create a form"
    expect(page.find("h1")).to have_text form.name
    expect(page.find(".govuk-tag.govuk-tag--purple")).to have_text "DRAFT"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_view_an_existing_form
    click_link form.name
    expect(page.find("h1")).to have_text "Create a form"
    expect(page.find("h1")).to have_text form.name
    expect_page_to_have_no_axe_errors(page)
  end

  def then_i_edit_the_name_of_the_form
    click_link "Edit the name of your form"
    expect(page).to have_field("What’s the name of your form?", with: form.name)
    expect_page_to_have_no_axe_errors(page)
    fill_in "What’s the name of your form?", with: "Another form of juggling"
    click_button "Save and continue"
  end

  def and_the_form_name_is_updated
    expect(page.find("h1")).to have_text "Create a form"
    expect(page.find("h1")).to have_text "Another form of juggling"
    expect_page_to_have_no_axe_errors(page)
  end
end
