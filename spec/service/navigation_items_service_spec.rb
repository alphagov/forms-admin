require "rails_helper"

describe NavigationItemsService do
  include Rails.application.routes.url_helpers

  let!(:provider) { :gds }
  let!(:user) { build(:user, provider:) }
  let!(:service) { described_class.new(user:) }
  let(:support_url) { "http://localhost:3002/support" }

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
        allow(Settings.forms_product_page).to receive(:support_url).and_return(support_url)
      end

      context "when user can manage other users" do
        let(:can_manage_user) { true }

        it "includes users in navigation items" do
          users_item = NavigationItemsService::NavigationItem.new(text: I18n.t("header.users"), href: users_path, active: false)
          expect(service.navigation_items).to include(users_item)
        end
      end

      context "when user can manage mous" do
        let(:can_manage_mous) { true }

        it "includes mous in navigation items" do
          mous_item = NavigationItemsService::NavigationItem.new(text: I18n.t("header.mous"), href: mou_signatures_path, active: false)
          expect(service.navigation_items).to include(mous_item)
        end
      end

      context "when user has provider basic_auth" do
        let(:provider) { :basic_auth }

        it "does not include signout" do
          expect(service.navigation_items).not_to(be_any { |item| item.text == I18n.t("header.sign_out") })
        end

        it "includes profile with empty href" do
          profile_item = NavigationItemsService::NavigationItem.new(text: user.name, href: nil, active: false)
          expect(service.navigation_items).to include(profile_item)
        end
      end

      context "when user has provider auth0" do
        let(:provider) { :auth0 }

        it "includes profile with empty href" do
          profile_item = NavigationItemsService::NavigationItem.new(text: user.name, href: nil, active: false)
          expect(service.navigation_items).to include(profile_item)
        end

        it "includes correct signout in navigation items" do
          signout_item = NavigationItemsService::NavigationItem.new(text: I18n.t("header.sign_out"), href: sign_out_path, active: false)
          expect(service.navigation_items).to include(signout_item)
        end
      end
    end

    context "when the support URL is configured" do
      it "includes a link to the support page" do
        support_item = NavigationItemsService::NavigationItem.new(text: I18n.t("header.support"), href: support_url, active: false)
        expect(service.navigation_items).to include(support_item)
      end
    end

    context "when the support URL is not configured" do
      let(:support_url) { nil }

      it "does not include a link to the support page" do
        support_item = NavigationItemsService::NavigationItem.new(text: I18n.t("header.support"), href: support_url, active: false)
        expect(service.navigation_items).not_to include(support_item)
      end
    end
  end
end
