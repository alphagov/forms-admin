require "rails_helper"

RSpec.describe Forms::SubmissionTypeInput, type: :model do
  subject(:submission_type_input) { described_class.new(form:, submission_type:) }

  let(:form) { build(:form, :live, submission_type: original_submission_type, submission_format: original_submission_format) }

  let(:original_submission_type) { "email" }
  let(:original_submission_format) { nil }
  let(:submission_type) { nil }

  describe "validation" do
    context "when set to 'email'" do
      let(:submission_type) { "email" }

      it "validates succesfully" do
        expect(submission_type_input).to be_valid
      end
    end

    context "when set to 'email_with_csv'" do
      let(:submission_type) { "email_with_csv" }

      it "validates succesfully" do
        expect(submission_type_input).to be_valid
      end
    end

    context "when given a nil value" do
      it "returns a validation error" do
        expect(submission_type_input).not_to be_valid
        expect(submission_type_input.errors.full_messages_for(:submission_type)).to include(
          "Submission type #{I18n.t('activemodel.errors.models.forms/submission_type_input.attributes.submission_type.blank')}",
        )
      end
    end
  end

  describe "#assign_form_value" do
    subject(:submission_type_input) { described_class.new(form:, submission_type:) }

    context "when form has submission type 'email_with_csv'" do
      let(:original_submission_type) { "email_with_csv" }

      it "set the submission type" do
        expect {
          submission_type_input.assign_form_values
        }.to change(submission_type_input, :submission_type).to original_submission_type
      end
    end

    context "when form has submission type 'email'" do
      let(:original_submission_type) { "email" }

      it "set the submission type" do
        expect {
          submission_type_input.assign_form_values
        }.to change(submission_type_input, :submission_type).to original_submission_type
      end
    end
  end

  describe "#submit" do
    context "when submission type has changed from 'email_with_csv' to 'email'" do
      let(:submission_type) { "email" }
      let(:original_submission_type) { "email_with_csv" }
      let(:original_submission_format) { %w[csv] }

      it "updates the form submission type" do
        expect {
          submission_type_input.submit
        }.to change(form, :submission_type).to(submission_type)
      end

      it "updates the form submission format" do
        expect {
          submission_type_input.submit
        }.to change(form, :submission_format).to([])
      end
    end

    context "when submission type has changed from 'email' to 'email_with_csv'" do
      let(:submission_type) { "email_with_csv" }
      let(:original_submission_type) { "email" }
      let(:original_submission_format) { [] }

      it "updates the form submission type" do
        expect {
          submission_type_input.submit
        }.to change(form, :submission_type).to(submission_type)
      end

      it "updates the form submission format" do
        expect {
          submission_type_input.submit
        }.to change(form, :submission_format).to(%w[csv])
      end
    end

    context "when submission type has not changed from 'email'" do
      let(:submission_type) { "email" }
      let(:original_submission_type) { "email" }
      let(:original_submission_format) { [] }

      it "does not change the form submission type" do
        expect {
          submission_type_input.submit
        }.not_to(change(form, :submission_type))
      end

      context "when the form submission format is not set" do
        let(:original_submission_format) { nil }

        it "sets the form submission type" do
          expect {
            submission_type_input.submit
          }.to change(form, :submission_format).to([])
        end
      end
    end

    context "when submission type has not changed from 'email_with_csv'" do
      let(:submission_type) { "email_with_csv" }
      let(:original_submission_type) { "email_with_csv" }
      let(:original_submission_format) { %w[csv] }

      it "does not change the form submission type" do
        expect {
          submission_type_input.submit
        }.not_to(change(form, :submission_type))
      end

      context "when the form submission format is not set" do
        let(:original_submission_format) { nil }

        it "sets the form submission type" do
          expect {
            submission_type_input.submit
          }.to change(form, :submission_format).to(%w[csv])
        end
      end
    end

    context "when given a nil value" do
      let(:submission_type) { nil }

      it "does not change the form submission type" do
        expect {
          submission_type_input.submit
        }.not_to(change(form, :submission_type))
      end

      it "does not change the form submission format" do
        expect {
          submission_type_input.submit
        }.not_to(change(form, :submission_format))
      end
    end
  end

  describe "#submission_format" do
    subject(:submission_type_input) { described_class.new(form:, submission_format:) }

    let(:submission_format) { nil }

    context "when set to []" do
      let(:submission_format) { [] }

      it "validates succesfully" do
        expect(submission_type_input).to be_valid
      end

      it "sets the submission_type to 'email'" do
        expect(submission_type_input.submission_type).to eq "email"
      end
    end

    context "when set to ['csv']" do
      let(:submission_format) { %w[csv] }

      it "validates succesfully" do
        expect(submission_type_input).to be_valid
      end

      it "sets the submission_type to 'email_with_csv'" do
        expect(submission_type_input.submission_type).to eq "email_with_csv"
      end
    end

    context "when given a nil value" do
      it "returns a validation error" do
        expect(submission_type_input).not_to be_valid
        expect(submission_type_input.errors.full_messages_for(:submission_type)).to include(
          "Submission type #{I18n.t('activemodel.errors.models.forms/submission_type_input.attributes.submission_type.blank')}",
        )
      end
    end
  end
end
