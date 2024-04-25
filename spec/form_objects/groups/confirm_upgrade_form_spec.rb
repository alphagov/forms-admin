require "rails_helper"

RSpec.describe Groups::ConfirmUpgradeForm, type: :model do
  describe "Confirm upgrade form" do
    describe("validation") do
      it "is invalid if blank" do
        confirm_upgrade_form = described_class.new(confirm: "")
        confirm_upgrade_form.validate(:confirm)

        expect(confirm_upgrade_form.errors.full_messages_for(:confirm)).to include(
          "Confirm Select yes if you want to upgrade this group",
        )
      end
    end
  end
end
