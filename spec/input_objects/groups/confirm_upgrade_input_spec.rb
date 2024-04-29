require "rails_helper"

RSpec.describe Groups::ConfirmUpgradeInput, type: :model do
  subject(:confirm_upgrade_input) { described_class.new(confirm:) }

  let(:confirm) { "yes" }

  describe "Confirm upgrade form" do
    describe("validations") do
      it "is valid if an option is selected" do
        confirm_upgrade_input.confirm = "yes"
        expect(confirm_upgrade_input).to be_valid
      end

      it "is invalid if blank" do
        confirm_upgrade_input.confirm = ""
        confirm_upgrade_input.validate(:confirm)

        expect(confirm_upgrade_input.errors.full_messages_for(:confirm))
          .to include("Confirm Select yes if you want to upgrade this group")
      end
    end
  end
end
