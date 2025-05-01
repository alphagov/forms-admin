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

    it "has includes the navigation items passed into it" do
      expect(page).to have_link("Your groups", href: "/")
      expect(page).to have_link("Support", href: "/support")
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
