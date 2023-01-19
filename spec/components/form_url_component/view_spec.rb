require "rails_helper"

RSpec.describe FormUrlComponent::View, type: :component do
  before do
    render_inline(described_class.new("https://example.com"))
  end

  it "renders the heading" do
    expect(page).to have_css("h2", text: "Form URL")
  end

  it "renders the link" do
    expect(page).to have_text("https://example.com")
  end
end
