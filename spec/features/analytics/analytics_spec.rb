require "rails_helper"

feature "Google analytics", type: :feature do
  before do
    allow(Settings).to receive(:analytics_enabled).and_return(analytics_enabled)
  end

  context "when the analytics setting is not enabled" do
    let(:analytics_enabled) { false }

    before do
      login_as_standard_user
    end

    it "does not load in Google Analytics" do
      visit root_path
      expect(page).not_to have_selector('script[src*="googletagmanager"]', visible: :hidden)
    end
  end

  context "when the analytics setting is enabled" do
    let(:analytics_enabled) { true }

    context "when the user is a super admin" do
      before do
        login_as_super_admin_user
      end

      it "does not load in Google Analytics" do
        visit root_path
        expect(page).not_to have_selector('script[src*="googletagmanager"]', visible: :hidden)
      end
    end

    context "when the user is not a super admin" do
      before do
        login_as_standard_user
      end

      it "loads in Google Analytics" do
        visit root_path
        expect(page).to have_selector('script[src*="googletagmanager"]', visible: :hidden)
      end
    end
  end
end
