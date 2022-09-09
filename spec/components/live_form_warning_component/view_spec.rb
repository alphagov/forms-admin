require "rails_helper"

RSpec.describe LiveFormWarningComponent::View, type: :component do
  context "when given tasks data as an array" do
    before do
      render_inline(described_class.new)
    end

    it "renders the title" do
      expect(page).to have_text("Important")
    end

    it "renders the heading" do
      expect(page).to have_text("Any changes you make to a live form will be updated in the form immediately.", normalize_ws: true)
    end

    it "renders the body" do
      expect(page).to have_text("This could have an impact on people who are filling in the form at the same time. They may lose any answers they have already provided and may need to start again.", normalize_ws: true)
    end
  end
end
