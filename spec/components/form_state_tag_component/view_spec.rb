require "rails_helper"

RSpec.describe FormStateTagComponent::View, type: :component do
  describe "draft/default status" do
    before do
      render_inline(described_class.new)
    end

    it "renders the draft status by default" do
      expect(page).to have_text("DRAFT")
    end

    it "renders draft status in purple" do
      expect(page).to have_css(".govuk-tag--purple")
    end
  end

  describe "live status" do
    before do
      render_inline(described_class.new(state: "live"))
    end

    it "renders the status text" do
      expect(page).to have_text("LIVE")
    end

    it "renders status in blue" do
      expect(page).to have_css(".govuk-tag--blue")
    end
  end

  # it "renders the link" do
  #   expect(page).to have_text("https://example.com")
  # end
end
