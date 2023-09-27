require "rails_helper"

describe "Request an upgrade from trial user to editor", type: :feature do
  let(:org_forms) do
    create :organisation, id: 1, slug: "test-org"
    [build(:form, id: 1, creator_id: 1, organisation_id: 1, name: "Org form")]
  end

  let(:trial_forms) do
    [build(:form, id: 2, creator_id: 2, organisation_id: nil, name: "Trial form")]
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

  it "the trial account banner is visible" do
    login_as trial_user
    then_i_can_see_trial_account_banner
    then_i_can_navigate_to_the_upgrade_page
    check_met_requirements
    submit_request
    then_i_can_see_request_sent_banner
  end

  # it "A trial user can request an upgrade when they declare they meet the requirements" do
  #   login_as trial_user
  #   visit_upgrade_page
  #   check I18n.t("helpers.label.user_upgrade_request.met_requirements_options.1")
  #   submit_request
  #   then_i_can_see_request_sent_banner
  # end

  it "A trial user cannot request an upgrade when they do not declare they meet the requirements" do
    login_as trial_user
    visit_upgrade_page
    submit_request
    then_i_see_an_error
  end

private

  def visit_upgrade_page
    visit new_user_upgrade_request_path
    expect(page).to have_text I18n.t("page_titles.user_upgrade_request_new")
  end

  def then_i_can_see_trial_account_banner
    visit root_path
    expect(page).to have_text "You have a trial account"
  end

  def check_met_requirements
    check I18n.t("helpers.label.user_upgrade_request.met_requirements_options.1")
  end

  def then_i_can_navigate_to_the_upgrade_page
    visit root_path

    click_link("Find out if you can upgrade to an editor account")

    expect(page).to have_current_path(user_upgrade_request_path)
  end

  def submit_request
    click_button I18n.t("continue")
  end

  def then_i_can_see_request_sent_banner
    expect(page).to have_text I18n.t("user_upgrade_request.show.panel_title")
  end

  def then_i_see_an_error
    expect(page).to have_text I18n.t("activemodel.errors.models.user_upgrade_request.attributes.met_requirements.accepted")
  end
end
