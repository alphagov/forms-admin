require "rails_helper"

describe "groups/review_upgrade.html.erb" do
  let(:current_user) { create(:user) }
  let(:group) { create(:group, upgrade_requester: current_user) }
  let(:confirm_upgrade_input) { Groups::ConfirmUpgradeInput.new }
  let(:page) { Capybara.string(rendered.html) }

  before do
    assign(:confirm_upgrade_input, confirm_upgrade_input)
    assign(:group, group)
  end

  context "when there are no errors" do
    before do
      render
    end

    it "has a back link to group page" do
      expect(view.content_for(:back_link)).to have_link("Back", href: group_path(group))
    end

    it "has a form that will POST to the correct URL" do
      expect(rendered).to have_css("form[action='#{review_upgrade_group_path(group)}'][method='post']")
      expect(rendered).to have_field("groups_confirm_upgrade_input[confirm]")
      expect(rendered).to have_button("Save and continue")
    end

    it "renders content containing the name of the user that requested an upgrade" do
      expect(rendered).to have_text("#{current_user.name} has asked to upgrade this group to an ‘active’ group.")
    end
  end

  context "when there are errors" do
    before do
      confirm_upgrade_input.errors.add(:confirm, "is required")
      render
    end

    it "displays the error summary" do
      expect(rendered).to have_selector(".govuk-error-summary")
    end

    it "displays an inline error message" do
      expect(page.find("fieldset", text: "Do you want to upgrade this group?")).to have_selector(".govuk-error-message")
    end

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix("Upgrade this group", true))
    end
  end
end
