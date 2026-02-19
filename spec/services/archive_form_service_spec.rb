require "rails_helper"

describe ArchiveFormService do
  subject(:archive_form_service) do
    described_class.new(form:, current_user:)
  end

  let(:submission_email) { "submission@example.gov.uk" }
  let(:form) { create(:form, :live, submission_email:) }
  let(:current_user) { build(:user) }
  let(:delivery) { double }

  describe "#archive" do
    before do
      allow(SubmissionEmailMailer).to receive(:alert_processor_form_archive)
                                        .with(anything)
                                        .and_return(delivery)
      allow(delivery).to receive(:deliver_now).with(no_args)
    end

    it "archives the form" do
      expect {
        archive_form_service.archive
      }.to change(form, :state).to("archived")
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

  describe "#archive_welsh_only" do
    let!(:form) { create(:form, :live, :with_welsh_translation) }
    let!(:welsh_form_document) { FormDocument.find_by(form:, tag: "live", language: "cy") }

    context "when the form has a welsh form document" do
      it "archives the welsh form document" do
        expect {
          archive_form_service.archive_welsh_only
        }.to change { welsh_form_document.reload.tag }.from("live").to("archived")
      end
    end
  end
end
