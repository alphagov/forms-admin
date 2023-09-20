require "rails_helper"

RSpec.describe TrialRoleWarningComponent::View, type: :component do
  before do
    render_inline(described_class.new(user))
  end

  context "when a user has the trial role" do
    let(:user) { build :user, :with_trial_role }

    it "displays a banner informing the user they have a trial account" do
      expect(page).to have_selector(".govuk-notification-banner__content")
      expect(page).to have_text("Important")
      expect(page).to have_text("You have a trial account")
      expect(page).to have_text("You can create a form, preview and test it.")
      expect(page).to have_text("You need an editor account to be able to make a form live.")
      expect(page).to have_link("Find out if you can upgrade to an editor account")
    end
  end

  context "when a user does not have the trial role" do
    let(:user) { build :user, role: :editor }

    it "does not display a banner" do
      expect(page).not_to have_selector(".govuk-notification-banner__content")
    end
  end
end
