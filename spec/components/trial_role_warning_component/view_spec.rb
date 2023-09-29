require "rails_helper"

RSpec.describe TrialRoleWarningComponent::View, type: :component do
  before do
    render_inline(described_class.new(link_url: "test-url"))
  end

  it "displays a banner with correct locale text" do
    expect(page).to have_selector(".govuk-notification-banner__content")
    expect(page).to have_content(I18n.t("trial_role_warning.heading"))
    expect(page).to have_content(Capybara.string(I18n.t("trial_role_warning.content_html", link_url: "test")).text(normalize_ws: true), normalize_ws: true)
    expect(page).to have_link(href: "test-url")
  end
end
