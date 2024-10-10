require "rails_helper"

RSpec.describe Forms::MarkCompleteInput, type: :model do
  let(:form) { build :form }
  let(:mark_complete_input) { described_class.new(mark_complete:, form:) }
  let(:mark_complete) { "true" }

  describe "validations" do
    context "when mark_complete is blank" do
      let(:mark_complete) { nil }

      it "is not valid" do
        expect(mark_complete_input).not_to be_valid
      end
    end

    context "when mark_complete is true" do
      let(:mark_complete) { "true" }

      it "is valid" do
        expect(mark_complete_input).to be_valid
      end
    end

    context "when mark_complete is false" do
      let(:mark_complete) { "false" }

      it "is valid" do
        expect(mark_complete_input).to be_valid
      end
    end
  end

  describe "marked_complete?" do
    context "when mark_complete is nil" do
      let(:mark_complete) { nil }

      it "returns false" do
        expect(mark_complete_input.marked_complete?).to be false
      end
    end

    context "when mark_complete is false" do
      let(:mark_complete) { "false" }

      it "returns false" do
        expect(mark_complete_input.marked_complete?).to be false
      end
    end

    context "when mark_complete is true" do
      let(:mark_complete) { "true" }

      it "returns false" do
        expect(mark_complete_input.marked_complete?).to be true
      end
    end
  end
end
