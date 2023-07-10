require "rails_helper"

feature "Set or change a user's organisation", type: :feature do
  let!(:test_org) do
    create(:organisation, id: 1, slug: "test-org")
  end
  let!(:gds_org) do
    create(:organisation, id: 2, slug: "government-digital-service")
  end

  let(:test_org_forms) do
    [build(:form, id: 1, org: "test-org", name: "Test Org Form")]
  end
  let(:gds_forms) do
    [build(:form, id: 2, org: "government-digital-service", name: "Test GDS Form")]
  end

  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?org=test-org", req_headers, test_org_forms.to_json, 200
      mock.get "/api/v1/forms?org=government-digital-service", req_headers, gds_forms.to_json, 200
    end

    create_list :user, 6, organisation: test_org

    login_as_super_admin_user
  end

  scenario "Super admin can change a user's organisation" do
    given_i_am_viewing_the_users_page
    and_i_choose_a_user_to_edit
    when_i_change_the_users_organisation
    then_the_users_organisation_name_is_updated
  end

  scenario "Super admin can change their own organisation" do
    given_i_am_a_super_admin_in_the_government_digital_service_organisation
    when_i_change_my_organisation_to_test_org
    then_i_cannot_see_the_government_digital_service_forms
    but_i_can_see_the_test_org_forms
  end

private

  def given_i_am_viewing_the_users_page
    visit users_path
  end

  def and_i_choose_a_user_to_edit
    edit_user_path_re = %r{/users/(?<id>\d+)/edit}
    edit_user_link = page.find_all(:link, href: edit_user_path_re).sample
    @user = User.find(edit_user_path_re.match(edit_user_link[:href])[:id])

    edit_user_link.click
    expect(page).to have_css "h1.govuk-heading-l", text: "Edit user"
    expect(page).to have_text @user.name
  end

  def when_i_change_the_users_organisation
    @old_organisation_name = @user.organisation&.name || I18n.t("users.index.organisation_blank")
    @new_organisation_name = Organisation.pluck(:name).reject { |name| name == @old_organisation_name }.sample
    select @new_organisation_name, from: "Organisation"
    click_button "Save"
  end

  def then_the_users_organisation_name_is_updated
    user_table_row = page.find(".govuk-table tr", text: @user.name)
    expect(user_table_row).to have_text @new_organisation_name
    expect(user_table_row).not_to have_text @old_organisation_name
  end

  def given_i_am_a_super_admin_in_the_government_digital_service_organisation
    @user = create(:user, role: "super_admin", organisation: gds_org)
    login_as @user

    visit edit_user_path(@user.id)
    expect(page).to have_text "Government Digital Service"

    visit root_path
    expect(page).to have_text "Test GDS Form"
  end

  def when_i_change_my_organisation_to_test_org
    visit edit_user_path(@user.id)
    select "Test Org", from: "Organisation"
    click_button "Save"
  end

  def then_i_cannot_see_the_government_digital_service_forms
    visit root_path
    expect(page).not_to have_text "Test GDS Form"
  end

  def but_i_can_see_the_test_org_forms
    visit root_path
    expect(page).to have_text "Test Org Form"
  end
end
