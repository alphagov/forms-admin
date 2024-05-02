require "rails_helper"

describe ArchiveFormService do
  subject(:archive_form_service) do
    described_class.new(form:, current_user:)
  end

  let(:submission_email) { "submission@example.gov.uk" }
  let(:form) { build(:form, submission_email:) }
  let(:current_user) { build(:user) }
  let(:delivery) { double }

  describe "#archive" do
    before do
      allow(form).to receive(:archive!)
      allow(SubmissionEmailMailer).to receive(:alert_processor_form_archive)
                                        .with(anything)
                                        .and_return(delivery)
      allow(delivery).to receive(:deliver_now).with(no_args)
    end

    it "calls archive! on the form" do
      expect(form).to receive(:archive!)
      archive_form_service.archive
    end

    it "sends an email to the submission email address" do
      expect(SubmissionEmailMailer).to receive(:alert_processor_form_archive)
                                         .with(processor_email: submission_email,
                                               form_name: form.name,
                                               archived_by_name: current_user.name,
                                               archived_by_email: current_user.email)
      expect(delivery).to receive(:deliver_now).with(no_args)
      archive_form_service.archive
    end
  end
end
