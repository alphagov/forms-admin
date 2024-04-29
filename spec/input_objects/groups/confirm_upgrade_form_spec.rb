require "rails_helper"

RSpec.describe Groups::ConfirmUpgradeForm, type: :model do
  subject(:confirm_upgrade_form) { described_class.new(confirm:) }

  let(:confirm) { "yes" }

  describe "Confirm upgrade form" do
    describe("validations") do
      it "is valid if an option is selected" do
        confirm_upgrade_form.confirm = "yes"
        expect(confirm_upgrade_form).to be_valid
      end

      it "is invalid if blank" do
        confirm_upgrade_form.confirm = ""
        confirm_upgrade_form.validate(:confirm)

        expect(confirm_upgrade_form.errors.full_messages_for(:confirm))
          .to include("Confirm Select yes if you want to upgrade this group")
      end
    end
  end
end
