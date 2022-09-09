require "rails_helper"

RSpec.describe FormUrlComponent::View, type: :component do
  before do
    render_inline(described_class.new("https://example.com"))
  end

  it "renders the intro text" do
    expect(page).to have_text("The URL for your form is")
  end

  it "renders the link" do
    expect(page).to have_text("https://example.com")
  end
end
