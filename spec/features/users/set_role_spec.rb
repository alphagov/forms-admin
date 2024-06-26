require "rails_helper"

context "when the groups feature is not enabled", feature_groups: false do
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

    let(:trial_user) do
      create(:user, :with_trial_role, id: 2)
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?organisation_id=1", headers, org_forms.to_json, 200
        mock.get "/api/v1/forms?creator_id=2", headers, trial_forms.to_json, 200
      end

      super_admin_user.organisation = gds_org
    end

    it "A trial user sees only forms they have created" do # rubocop:disable RSpec/NoExpectationExample
      login_as_trial_user
      then_i_can_see_the_trial_user_forms
      then_i_cannot_see_the_org_forms
    end

    it "A trial user's forms move to their organisation on role upgrade" do # rubocop:disable RSpec/NoExpectationExample
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?organisation_id=1", headers, (org_forms + trial_forms).to_json, 200
        mock.patch "/api/v1/forms/update-organisation-for-creator?creator_id=2&organisation_id=1", post_headers, nil, 204
      end

      login_as_super_admin_user
      when_i_change_the_trial_users_role_to_editor
      reset_session!

      trial_user.reload
      login_as_trial_user
      then_i_can_see_the_trial_user_forms
      then_i_can_see_the_org_forms
    end

  private

    def when_i_change_the_trial_users_role_to_editor
      visit edit_user_path(trial_user.id)

      expect(page).to have_css "h1.govuk-heading-l", text: "Edit user"
      expect(page).to have_text trial_user.email

      fill_in "Name", with: "Test Name"
      fill_in "Organisation", with: "Test Org\n"
      choose("Editor")
      click_button "Save"

      expect(page).not_to have_css ".govuk-error-summary"
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
end
