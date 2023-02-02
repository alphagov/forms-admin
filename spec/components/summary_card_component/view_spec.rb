# frozen_string_literal: true

require "rails_helper"

describe SummaryCardComponent::View, type: :component do
  before do
    render_inline(described_class.new(title: "Lando Calrissian", heading_level: 6, rows:))
  end

  let(:rows) do
    [
      { key: "Character", value: "Lando Calrissian" },
      { key: "Location", value: "In a galaxy" },
      { key: "Transport", value: "Falcon", action_href: "#mike", action_text: "Change" },
    ]
  end

  it "renders a summary list component for rows" do
    expect(page).to have_css(".govuk-summary-list__value", text: "Lando Calrissian")
    expect(page).to have_css(".govuk-summary-list__key", text: "Character")
  end

  it "renders content at the top of a summary card" do
    expect(page).to have_text("In a galaxy")
  end

  it "renders a summary card header component with a title only" do
    expect(page).to have_css(".app-summary-card__title", text: "Lando Calrissian")
  end

  it "renders a summary card header component with a custom heading level" do
    expect(page).to have_css(".app-summary-card__title", text: "Lando Calrissian")
    expect(page).to have_css("h6.app-summary-card__title")
  end
end
