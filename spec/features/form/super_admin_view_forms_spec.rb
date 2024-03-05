require "rails_helper"

feature "View forms", type: :feature do
  let(:org_forms) { [build(:form, id: 1, name: "Org form")] }
  let(:other_org) { create :organisation, id: 2, slug: "Other org" }
  let(:other_org_user) { create :user, organisation: other_org }
  let(:other_org_forms) { [build(:form, id: 2, organisation_id: other_org.id, name: "Other org form")] }

  let(:headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?organisation_id=#{super_admin_user.organisation_id}", headers, org_forms.to_json, 200
      mock.get "/api/v1/forms?organisation_id=#{other_org.id}", headers, other_org_forms.to_json, 200
    end

    # Orgs only show in the autocomplete if they have at least one user
    other_org_user
    login_as_super_admin_user
  end

  scenario "Super admin can use autcomplete to view other org's forms" do
    visit root_path
    when_i_change_the_organisation
    then_i_should_see_the_forms_for_that_organisation
  end

  def when_i_change_the_organisation
    fill_in "search-organisation-id-field", with: other_org.name.to_s
    page.send_keys :enter
    click_button "Change"
  end

  def then_i_should_see_the_forms_for_that_organisation
    expect(page).to have_content(other_org_forms.first.name)
  end
end
