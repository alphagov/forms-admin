require "rails_helper"

describe "Set or change a user's role", type: :feature do
  let!(:gds_org) do
    create :organisation, id: 2, slug: "government-digital-service"
  end

  let(:org_forms) do
    create :organisation, id: 1, slug: "test-org"
    [build(:form, id: 1, creator_id: 1, organisation_id: 1, name: "Org form")]
  end

  let(:trial_forms) do
    [build(:form, id: 2, creator_id: 2, organisation_id: nil, name: "Trial form")]
  end

  let(:super_admin_user) do
    create(:user, role: :super_admin, id: 1, organisation: gds_org)
  end

  let(:trial_user) do
    create(:user, :with_trial_role, id: 2)
  end

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
      mock.get "/api/v1/forms?creator_id=2", req_headers, trial_forms.to_json, 200
    end
  end

  it "A trial user sees only forms they have created" do
    login_as trial_user
    then_i_can_see_the_trial_user_forms
    then_i_cannot_see_the_org_forms
  end

  it "A trial user's forms move to their organisation on role upgrade" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?organisation_id=1", req_headers, (org_forms + trial_forms).to_json, 200
      mock.patch "/api/v1/forms/update-organisation-for-creator?creator_id=2&organisation_id=1", post_headers, nil, 204
    end

    login_as super_admin_user
    when_i_change_the_trial_users_role_to_editor
    reset_session!

    login_as trial_user.reload
    then_i_can_see_the_trial_user_forms
    then_i_can_see_the_org_forms
  end

private

  def when_i_change_the_trial_users_role_to_editor
    visit edit_user_path(trial_user.id)

    expect(page).to have_css "h1.govuk-heading-l", text: "Edit user"
    expect(page).to have_text trial_user.name

    fill_in "Organisation", with: "Test Org\n"
    choose("Editor")
    click_button "Save"
  end

  def then_i_can_see_the_trial_user_forms
    visit root_path
    expect(page).to have_text "Trial form"
  end

  def then_i_cannot_see_the_org_forms
    visit root_path
    expect(page).not_to have_text "Org form"
  end

  def then_i_can_see_the_org_forms
    visit root_path
    expect(page).to have_text "Org form"
  end
end
