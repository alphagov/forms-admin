require "rails_helper"

describe "groups/confirm_upgrade.html.erb" do
  let(:group) { create(:group) }
  let(:confirm_upgrade_input) { Groups::ConfirmUpgradeInput.new }

  before do
    assign(:confirm_upgrade_input, confirm_upgrade_input)
    assign(:group, group)
  end

  context "when there are no errors" do
    before do
      render
    end

    it "displays the form" do
      expect(rendered).to have_selector("form[action='#{upgrade_group_path(group)}'][method='post']")
      expect(rendered).to have_field("groups_confirm_upgrade_input[confirm]")
      expect(rendered).to have_button("Save and continue")
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

    it "sets the page title with error prefix" do
      expect(view.content_for(:title)).to eq(title_with_error_prefix("Upgrade this group", true))
    end
  end
end
