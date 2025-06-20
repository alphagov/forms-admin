require "rails_helper"

describe "layouts/base.html.erb" do
  let(:analytics_events) { [] }
  let(:user) { instance_double(User, collect_analytics?: true) }

  before do
    without_partial_double_verification do
      allow(view).to receive_messages(
        success: false,
      )
    end
    allow(AnalyticsService).to receive(:analytics_events).and_return(analytics_events)
    assign(:current_user, user)
  end

  context "when analytics events are present and user allows analytics collection" do
    let(:analytics_events) do
      [
        { properties: { action: "view_page", page: "home" } },
        { properties: { action: "click_button", button: "submit" } },
      ]
    end

    it "renders the analytics script tag" do
      render
      expect(rendered).to have_css("script[data-analytics-events]", visible: :all)
    end

    it "includes the correct datalayer events" do
      render

      analytics_script = Capybara.string(rendered).find("script[data-analytics-events]", visible: :all).text

      expect(analytics_script).to include("\"view_page\"")
      expect(analytics_script).to include("\"home\"")

      expect(analytics_script).to include("\"click_button\"")
      expect(analytics_script).to include("\"submit\"")
    end
  end

  context "when analytics events are not present" do
    let(:analytics_events) { [] }

    it "does not render the analytics script tag" do
      render
      expect(rendered).not_to have_selector("script[data-analytics-events]")
    end
  end

  context "when collect_analytics? is false" do
    let(:analytics_events) do
      [{ properties: { action: "view_page", page: "home" } }]
    end
    let(:user) { instance_double(User, collect_analytics?: false) }

    it "does not render the analytics script tag" do
      render
      expect(rendered).not_to have_selector("script[data-analytics-events]")
    end
  end

  context "when user is nil" do
    let(:analytics_events) do
      [{ properties: { action: "view_page", page: "home" } }]
    end

    before do
      assign(:current_user, nil)
    end

    it "does not render the analytics script tag" do
      render
      expect(rendered).not_to have_selector("script[data-analytics-events]")
    end
  end
end
