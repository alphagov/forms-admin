require "rails_helper"

RSpec.describe Forms::ReceiveCsvInput, type: :model do
  describe "Receive CSV input" do
    subject(:receive_csv_input) { described_class.new(form:, submission_type:) }

    let(:form) do
      build(:form, :live)
    end

    let(:submission_type) { nil }

    context "when set to 'email'" do
      let(:submission_type) { "email" }

      it "validates succesfully" do
        expect(receive_csv_input).to be_valid
      end
    end

    context "when set to 'email_with_csv'" do
      let(:submission_type) { "email_with_csv" }

      it "validates succesfully" do
        expect(receive_csv_input).to be_valid
      end
    end

    context "when given a nil value" do
      it "returns a validation error" do
        expect(receive_csv_input).not_to be_valid
        expect(receive_csv_input.errors.full_messages_for(:submission_type)).to include(
          "Submission type can't be blank",
        )
      end
    end
  end
end
