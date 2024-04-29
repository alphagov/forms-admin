require "rails_helper"

RSpec.describe Forms::ConfirmArchiveInput, type: :model do
  describe "Confirm archive form" do
    it "is invalid if blank" do
      confirm_archive_input = described_class.new(confirm: "")
      confirm_archive_input.validate(:confirm)

      expect(confirm_archive_input.errors.full_messages_for(:confirm)).to include(
        "Confirm Select yes if you want to archive this form",
      )
    end
  end
end
