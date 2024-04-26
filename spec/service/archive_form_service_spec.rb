require "rails_helper"

describe ArchiveFormService do
  describe "#archive_form" do
    let(:form) { build(:form, :live) }
    let(:user) { build(:user) }

    it "archives the form" do
      expect(form).to receive(:archive!)
      expect(SubmissionEmailMailer).to receive(:alert_processor_form_archive)

      described_class.new.archive_form(form, user)
    end
  end
end
