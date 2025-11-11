require "rails_helper"

RSpec.describe Forms::SubmissionAttachmentsInput, type: :model do
  describe "validation" do
    let(:form) { create(:form) }

    context "when given a valid CSV and JSON submission format" do
      let(:submission_format) { %w[csv json] }

      it "validates succesfully" do
        submission_attachments_input = described_class.new(form:, submission_format:)

        expect(submission_attachments_input).to be_valid
      end
    end

    context "when given a valid no attachments submission format" do
      let(:submission_format) { [""] }

      it "validates succesfully" do
        submission_attachments_input = described_class.new(form:, submission_format:)

        expect(submission_attachments_input).to be_valid
      end
    end

    context "when given an invalid submission format" do
      let(:submission_format) { %w[apple json] }

      it "returns a validation error" do
        submission_attachments_input = described_class.new(form:, submission_format:)

        submission_attachments_input.validate

        expect(submission_attachments_input.errors.full_messages_for(:base)).to include("Sorry, there was a problem. Please try again.")
      end
    end

    context "when not given a submission format" do
      it "returns a validation error" do
        submission_attachments_input = described_class.new(form:)

        submission_attachments_input.validate

        expect(submission_attachments_input.errors.full_messages_for(:submission_format)).to include("Submission format Sorry, there was a problem. Please try again.")
      end
    end
  end

  describe "#submit" do
    let(:form) { create(:form, submission_format: []) }

    context "when valid" do
      subject(:submission_attachments_input) { described_class.new(form:, submission_format: updated_submission_format) }

      let(:updated_submission_format) { %w[csv] }

      it "updates the form's submission_format" do
        expect {
          submission_attachments_input.submit
        }.to change(form, :submission_format).to(updated_submission_format)
      end
    end

    context "when invalid" do
      subject(:submission_attachments_input) { described_class.new(form:, submission_format: updated_submission_format) }

      let(:updated_submission_format) { %w[banana] }

      it "does not update the form's submission_format" do
        expect {
          submission_attachments_input.submit
        }.not_to change(form, :submission_format)
      end
    end
  end

  describe "#assign_form_values" do
    subject(:submission_attachments_input) { described_class.new(form:) }

    context "when the original form has an empty array submission format" do
      let(:form) { create(:form, submission_format: []) }

      it "sets the submission format value to an empty array" do
        submission_attachments_input.assign_form_values

        expect(submission_attachments_input.submission_format).to eq([])
      end
    end

    context "when the original form has a csv and json submission format" do
      let(:form) { create(:form, submission_format: %w[csv json]) }

      it "sets the submission format value to an empty array" do
        submission_attachments_input.assign_form_values

        expect(submission_attachments_input.submission_format).to eq(%w[csv json])
      end
    end
  end
end
