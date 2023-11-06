require "rails_helper"

RSpec.describe RoleUpgradeComponent::View, type: :component do
  before do
    render_inline(described_class.new)
  end

  it "displays a banner with correct locale text" do
    expect(page).to have_selector(".govuk-notification-banner__content")
    expect(page).to have_content(I18n.t("role_upgrade.heading"))
    expect(page).to have_content(Capybara.string(I18n.t("role_upgrade.content_html")).text(normalize_ws: true), normalize_ws: true)
  end
end
