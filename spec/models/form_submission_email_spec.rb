require "rails_helper"

describe FormSubmissionEmail, type: :model do
  subject(:form_submission_email) { described_class.new }

  describe "validations" do
    it "requires a form_id" do
      form_submission_email.form_id = 123_456
      form_submission_email.temporary_submission_email = "test@example.gov.uk"
      expect(form_submission_email).to be_valid
    end

    context "when temporary_submission_email contains multiple email addresses" do
      it "is invalid with comma-separated email addresses" do
        form_submission_email.form_id = 123_456
        form_submission_email.temporary_submission_email = "first@example.gov.uk,second@example.gov.uk"
        expect(form_submission_email).to be_invalid
      end

      it "is invalid with semi-colon-separated email addresses" do
        form_submission_email.form_id = 123_456
        form_submission_email.temporary_submission_email = "first@example.gov.uk;second@example.gov.uk"
        expect(form_submission_email).to be_invalid
      end

      it "is invalid with comma-separated email addresses with spaces" do
        form_submission_email.form_id = 123_456
        form_submission_email.temporary_submission_email = "first@example.gov.uk, second@example.gov.uk"
        expect(form_submission_email).to be_invalid
      end

      it "is invalid with semi-colon-separated email addresses with spaces" do
        form_submission_email.form_id = 123_456
        form_submission_email.temporary_submission_email = "first@example.gov.uk; second@example.gov.uk"
        expect(form_submission_email).to be_invalid
      end

      it "is valid with a single email address" do
        form_submission_email.form_id = 123_456
        form_submission_email.temporary_submission_email = "single@example.gov.uk"
        expect(form_submission_email).to be_valid
      end
    end
  end
end
