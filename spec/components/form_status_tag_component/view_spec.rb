require "rails_helper"

RSpec.describe FormStatusTagComponent::View, type: :component do
  describe "draft/default status" do
    before do
      render_inline(described_class.new)
    end

    it "renders the draft status by default" do
      expect(page).to have_text("Draft")
    end

    it "renders draft status in yellow" do
      expect(page).to have_css(".govuk-tag--yellow")
    end
  end

  describe "live status" do
    before do
      render_inline(described_class.new(status: :live))
    end

    it "renders the status text" do
      expect(page).to have_text("Live")
    end

    it "renders status in turquoise" do
      expect(page).to have_css(".govuk-tag--turquoise")
    end
  end

  describe "string status" do
    it "accepts status as a string" do
      expect(described_class.new(status: "draft").status_colour).to eq "yellow"
      expect(described_class.new(status: "live").status_colour).to eq "turquoise"
    end
  end
end
