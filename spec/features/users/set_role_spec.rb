require "rails_helper"

describe "Set or change a user's role", type: :feature do
  let(:org_forms) do
    [build(:form, id: 1, creator_id: 1, org: "test-org", name: "Org form")]
  end

  let(:trial_forms) do
    [build(:form, id: 2, creator_id: 2, org: nil, name: "Trial form")]
  end

  let(:super_admin_user) do
    build(:user, :with_super_admin, id: 1)
  end

  let(:trial_user) do
    build(:user, :with_no_org, :with_trial, id: 2)
  end

  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  before do
    Rails.application.load_seed

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?org=test-org", req_headers, org_forms.to_json, 200
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
      mock.get "/api/v1/forms?org=test-org", req_headers, (org_forms + trial_forms).to_json, 200
    end

    login_as super_admin_user
    when_i_change_a_trial_users_role_to_editor
    login_as trial_user
    then_i_can_see_the_trial_user_forms
    then_i_can_see_the_org_forms
  end

private

  def when_i_change_a_trial_users_role_to_editor
    visit users_path
    edit_user_path_re = %r{/users/(?<id>\d+)/edit}
    edit_user_link = page.find_all(:link, href: edit_user_path_re).sample
    @user = User.find(edit_user_path_re.match(edit_user_link[:href])[:id])

    edit_user_link.click
    expect(page).to have_css "h1.govuk-heading-l", text: "Edit user"
    expect(page).to have_text @user.name

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
