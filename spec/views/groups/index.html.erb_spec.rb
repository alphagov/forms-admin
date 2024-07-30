require "rails_helper"

RSpec.describe "groups/index", type: :view do
  let(:trial_groups) { create_list :group, 2 }
  let(:upgrade_requested_groups) { create_list :group, 2, status: :upgrade_requested }
  let(:active_groups) { create_list :group, 2, status: :active }
  let(:current_user) { build :user }

  before do
    assign(:trial_groups, trial_groups)
    assign(:upgrade_requested_groups, upgrade_requested_groups)
    assign(:active_groups, active_groups)

    assign(:current_user, current_user)
  end

  context "when the user is not a super admin" do
    before do
      render
    end

    it "renders a list of groups" do
      trial_groups.each do |group|
        expect(rendered).to have_link(group.name, href: group_path(group))
      end

      upgrade_requested_groups.each do |group|
        expect(rendered).to have_link(group.name, href: group_path(group))
      end

      active_groups.each do |group|
        expect(rendered).to have_link(group.name, href: group_path(group))
      end
    end

    it "shows a create group button" do
      expect(rendered).to have_link("Create a group", href: new_group_path)
    end

    it "does not show an organisation selector" do
      expect(rendered).not_to have_select "search[organisation_id]"
    end

    context "when the user has a standard role" do
      context "and org has not signed an MOU" do
        let(:current_user) do
          instance_double User, standard?: true, organisation_admin?: false, super_admin?: false, current_org_has_mou?: false
        end

        it "shows the details text for users who are not org/super admins" do
          expect(rendered).to have_content("If you need access to an existing form or group, ask someone who has access to that group to add you.")
        end

        it "shows a notification banner explaining forms cannot be made live" do
          expect(rendered).to have_css ".govuk-notification-banner", text: "You cannot make any forms live yet"
        end
      end

      context "and org has signed an MOU" do
        let(:current_user) { build :user, :org_has_signed_mou }

        it "does not show a banner" do
          expect(rendered).not_to have_css ".govuk-notification-banner"
        end
      end
    end

    context "when the user is an organisation admin" do
      let(:current_user) { build :organisation_admin_user }

      it "shows the details text for admins" do
        expect(rendered).to have_content("Because you’re an organisation admin, you can access all the groups in your organisation.")
      end

      it "does not show an organisation selector" do
        expect(rendered).not_to have_select "search[organisation_id]"
      end

      context "when there is a single group with an upgrade requested" do
        let(:upgrade_requested_groups) { create_list :group, 1, status: :upgrade_requested }

        it "shows a notification banner" do
          expect(rendered).to have_css ".govuk-notification-banner", text: "You have one request to upgrade a trial group"
        end
      end

      context "when there is more than one group with an upgrade requested" do
        let(:upgrade_requested_groups) { create_list :group, 2, status: :upgrade_requested }

        it "shows a notification banner with pluralized message" do
          expect(rendered).to have_css ".govuk-notification-banner", text: "You have 2 requests to upgrade a trial group"
        end
      end

      context "when there are no groups with an upgrade requested" do
        let(:upgrade_requested_groups) { [] }

        it "does not show a notification banner" do
          expect(rendered).not_to have_css ".govuk-notification-banner"
        end
      end
    end
  end

  context "when the user is a super admin" do
    let(:current_user) { build :super_admin_user }
    let(:search_input) { OrganisationSearchInput.new({ organisation_id: current_user.organisation_id }) }

    before do
      assign(:search_input, search_input)
      render
    end

    it "shows an organisation selector" do
      expect(rendered).to have_select "search[organisation_id]"
    end
  end
end
