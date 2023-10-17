require "rails_helper"

describe NavigationItemsService do
  include Rails.application.routes.url_helpers

  let!(:provider) { nil }
  let!(:user) { build(:user, provider:) }
  let!(:service) { described_class.new(user:) }

  describe "#navigation_items" do
    context "when user is not present" do
      let(:user) { nil }

      it "returns an empty array" do
        expect(service.navigation_items).to be_empty
      end
    end

    context "when user is present" do
      let(:can_manage_user) { false }
      let(:can_manage_mous) { false }

      before do
        allow(Pundit).to receive(:policy).with(user, :user).and_return(instance_double(UserPolicy, can_manage_user?: can_manage_user))
        allow(Pundit).to receive(:policy).with(user, :mou_signature).and_return(instance_double(MouSignaturePolicy, can_manage_mous?: can_manage_mous))
      end

      context "when user can manage other users" do
        let(:can_manage_user) { true }

        it "includes users in navigation items" do
          users_item = NavigationItemsService::NavigationItem.new(I18n.t("header.users"), users_path, false)
          expect(service.navigation_items).to include(users_item)
        end
      end

      context "when user can manage mous" do
        let(:can_manage_mous) { true }

        it "includes mous in navigation items" do
          mous_item = NavigationItemsService::NavigationItem.new(I18n.t("header.mous"), mou_signatures_path, false)
          expect(service.navigation_items).to include(mous_item)
        end
      end

      context "when user has provider gds" do
        let(:provider) { :gds }

        it "includes correct profile in navigation items" do
          profile_item = NavigationItemsService::NavigationItem.new(user.name, GDS::SSO::Config.oauth_root_url, false)
          expect(service.navigation_items).to include(profile_item)
        end

        it "includes correct signout in navigation items" do
          signout_item = NavigationItemsService::NavigationItem.new(I18n.t("header.sign_out"), gds_sign_out_path, false)
          expect(service.navigation_items).to include(signout_item)
        end
      end

      context "when user has provider basic_auth" do
        let(:provider) { :basic_auth }

        it "does not include signout" do
          expect(service.navigation_items).not_to(be_any { |item| item.text == I18n.t("header.sign_out") })
        end

        it "includes profile with empty href" do
          profile_item = NavigationItemsService::NavigationItem.new(user.name, nil, false)
          expect(service.navigation_items).to include(profile_item)
        end
      end

      context "when user has provider auth0" do
        let(:provider) { :auth0 }

        it "includes profile with empty href" do
          profile_item = NavigationItemsService::NavigationItem.new(user.name, nil, false)
          expect(service.navigation_items).to include(profile_item)
        end

        it "includes correct signout in navigation items" do
          signout_item = NavigationItemsService::NavigationItem.new(I18n.t("header.sign_out"), sign_out_path, false)
          expect(service.navigation_items).to include(signout_item)
        end
      end

      context "when user has provider cddo_sso" do
        let(:provider) { :cddo_sso }

        it "includes profile with empty href" do
          profile_item = NavigationItemsService::NavigationItem.new(user.name, "https://sso.service.security.gov.uk/profile", false)
          expect(service.navigation_items).to include(profile_item)
        end

        it "includes correct signout in navigation items" do
          signout_item = NavigationItemsService::NavigationItem.new(I18n.t("header.sign_out"), sign_out_path, false)
          expect(service.navigation_items).to include(signout_item)
        end
      end
    end
  end
end
