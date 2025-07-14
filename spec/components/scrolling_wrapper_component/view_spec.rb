require "rails_helper"

RSpec.describe ScrollingWrapperComponent::View, type: :component do
  let(:aria_label) { "An accessible name for the contents of the component" }

  let(:scrolling_wrapper_component) do
    described_class.new(aria_label:)
  end

  let(:contents) do
    '<p class="govuk-body">Some content</p>'.html_safe
  end

  let(:current_page) { "/" }

  before do
    render_inline scrolling_wrapper_component do
      contents
    end
  end

  describe "render" do
    it "has the app-scrolling-wrapper class" do
      expect(page).to have_css(".app-scrolling-wrapper")
    end

    it "has tabindex set to 0 so it can be focused and scrolled by keyboard users" do
      expect(page).to have_css("[tabindex=0]")
    end

    it "has a region role and a label so that the purpose of the container is clear to assistive technology users" do
      expect(page).to have_css("[role='region'][aria-label='#{aria_label}']")
    end

    it "yields the content passed into it" do
      expect(page).to have_css("p", text: "Some content")
    end
  end
end
