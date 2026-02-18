require "rails_helper"

RSpec.describe Forms::ConfirmArchiveWelshInput, type: :model do
  describe "Confirm archive form" do
    it "is invalid if blank" do
      confirm_archive_input = described_class.new(confirm: "")
      confirm_archive_input.validate(:confirm)

      expect(confirm_archive_input.errors.full_messages_for(:confirm)).to include(
        "Confirm Select ‘Yes’ if you want to archive the Welsh version of this form",
      )
    end
  end
end
