require "rails_helper"

RSpec.describe ServiceNavigationComponent::View, type: :component do
  let(:navigation_items) do
    [
      NavigationItemsService::NavigationItem.new(text: "Your groups", href: "/", active: false),
      NavigationItemsService::NavigationItem.new(text: "Support", href: "/support", active: false),
    ]
  end

  let(:service_navigation_component) do
    described_class.new(navigation_items:)
  end

  let(:current_page) { "/" }

  before do
    with_request_url current_page do
      render_inline service_navigation_component
    end
  end

  describe "render" do
    it "has the app-service-navigation class" do
      expect(page).to have_css(".app-service-navigation")
    end

    context "when no sign-in link is supplied" do
      it "has no items with the app-service-navigation__item--featured" do
        expect(page).not_to have_css(".app-service-navigation__item--featured")
        expect(page).not_to have_link("Sign in")
      end
    end

    context "when a featured link is supplied" do
      let(:service_navigation_component) do
        described_class.new(navigation_items:, featured_link: { text: "Sign out", href: "/sign-out" })
      end

      it "has an item with the app-service-navigation__item--featured" do
        expect(page).to have_css(".app-service-navigation__item--featured", text: "Sign out")
        expect(page).to have_link("Sign out", href: "/sign-out")
      end
    end

    context "when on the 'Your groups' page" do
      it "renders the 'Your groups' navigation item as active" do
        expect(
          page.find(".govuk-service-navigation__item", text: "Your groups"),
        ).to match_selector ".govuk-service-navigation__item--active"
      end
    end
  end
end
