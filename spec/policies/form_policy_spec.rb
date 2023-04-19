require "rails_helper"

describe FormPolicy do
  subject(:policy) { described_class.new(user, form) }

  let(:form) { build :form, org: "gds" }
  let(:user) { build :user, organisation_slug: "gds" }

  describe "#can_view_form?" do
    context "with a form editor" do
      it { is_expected.to permit_actions(%i[can_view_form]) }

      context "but from another organisation" do
        let(:user) { build :user, organisation_slug: "non-gds" }

        it { is_expected.to forbid_actions(%i[can_view_form]) }
      end
    end
  end

  describe "#can_add_page_routing_conditions?" do
    describe "with a form editor" do
      it { is_expected.to forbid_actions(%i[can_add_page_routing_conditions]) }

      context "when feature flag is enabled", feature_basic_routing: true do
        it { is_expected.to permit_actions(%i[can_add_page_routing_conditions]) }
      end
    end

    describe "with a super admin user" do
      let(:user) { build :user, :with_super_admin, organisation_slug: "gds" }

      it { is_expected.to permit_actions(%i[can_add_page_routing_conditions]) }

      context "when feature flag is enabled", feature_basic_routing: true do
        it { is_expected.to permit_actions(%i[can_add_page_routing_conditions]) }
      end
    end
  end

  describe FormPolicy::Scope do
    subject(:policy_scope) { described_class.new(user, Form) }

    let(:headers) do
      {
        "X-API-Token" => Settings.forms_api.auth_key,
        "Accept" => "application/json",
      }
    end

    let(:gds_forms) { build_list :form, 2, org: "gds" }

    context "with a form editor" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms?org=gds", headers, gds_forms.to_json, 200
        end
        policy_scope.resolve
      end

      it "Reads the forms from the API" do
        forms_request = ActiveResource::Request.new(:get, "/api/v1/forms?org=gds", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include forms_request
      end
    end

    context "with a user with no organisation_slug" do
      let(:user) { build :user, organisation_slug: nil }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms?org=", headers, gds_forms.to_json, 200
        end
      end

      it "throws an eception" do
        expect { policy_scope.resolve }.to raise_error(FormPolicy::UserMissingOrganisationError)
        forms_request = ActiveResource::Request.new(:get, "/api/v1/forms?org=", {}, headers)
        expect(ActiveResource::HttpMock.requests).not_to include forms_request
      end
    end
  end
end
