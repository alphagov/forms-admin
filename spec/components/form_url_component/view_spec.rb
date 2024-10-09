require "rails_helper"

RSpec.describe FormUrlComponent::View, type: :component do
  context "when translations are not passed to the component" do
    before do
      render_inline(described_class.new(runner_link: "https://example.com"))
    end

    it "renders the heading with default text" do
      expect(page).to have_css("h2", text: "Form URL")
    end

    it "renders the link" do
      expect(page).to have_text("https://example.com")
    end

    it "has data-copy-button-text attribute set to default button text" do
      expect(page).to have_css("[data-copy-button-text='Copy URL to clipboard']")
    end
  end

  context "when translations are passed to the component" do
    let(:heading_text) { "Some heading" }
    let(:button_text) { "A button" }

    before do
      render_inline(described_class.new(runner_link: "https://example.com", heading_text:, button_text:))
    end

    it "renders the heading with the provided heading text" do
      expect(page).to have_css("h2", text: heading_text)
    end

    it "has data-copy-button-text attribute set to the provided button text" do
      expect(page).to have_css("[data-copy-button-text='#{button_text}']")
    end
  end
end
