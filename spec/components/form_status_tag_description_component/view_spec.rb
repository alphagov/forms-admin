require "rails_helper"

RSpec.describe FormStatusTagDescriptionComponent::View, type: :component do
  describe "draft/default status" do
    before do
      render_inline(described_class.new)
    end

    it "renders the draft status by default" do
      expect(page).to have_text("Draft")
    end
  end

  describe "live status" do
    before do
      render_inline(described_class.new(status: "live"))
    end

    it "renders the status text" do
      expect(page).to have_text("Live")
    end
  end
end
