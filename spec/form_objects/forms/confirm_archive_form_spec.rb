require "rails_helper"

RSpec.describe Forms::ConfirmArchiveForm, type: :model do
  describe "Confirm archive form" do
    it "is invalid if blank" do
      confirm_archive_form = described_class.new(confirm_archive: "")
      confirm_archive_form.validate(:confirm_archive)

      expect(confirm_archive_form.errors.full_messages_for(:confirm_archive)).to include(
        "Confirm archive Select yes if you want to archive this form",
      )
    end
  end
end
