require "rails_helper"

describe Condition do
  let(:validation_errors) { [] }
  let(:condition) { described_class.new(id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3, validation_errors:) }

  describe "#has_errors?" do
    context "when condition has no errors" do
      it "returns false" do
        expect(condition.has_errors?).to be false
      end
    end

    context "when condition has an error" do
      let(:validation_errors) { [OpenStruct.new(name: "answer_value_doesnt_exist")] }

      it "returns true" do
        expect(condition.has_errors?).to be true
      end
    end
  end

  describe "#errors_include?" do
    context "when condition has no errors" do
      it "returns false" do
        expect(condition.errors_include?("answer_value_doesnt_exist")).to be false
      end
    end

    context "when condition contains a different error" do
      let(:validation_errors) { [OpenStruct.new(name: "goto_page_doesnt_exist")] }

      it "returns false" do
        expect(condition.errors_include?("answer_value_doesnt_exist")).to be false
      end
    end

    context "when condition contains the relevant error" do
      let(:validation_errors) { [OpenStruct.new(name: "answer_value_doesnt_exist")] }

      it "returns true" do
        expect(condition.errors_include?("answer_value_doesnt_exist")).to be true
      end
    end
  end

  describe "#errors_with_fields" do
    context "when the error is a known error" do
      let(:validation_errors) { [OpenStruct.new(name: "answer_value_doesnt_exist"), OpenStruct.new(name: "goto_page_doesnt_exist")] }

      it "returns the correct values for each error type" do
        expect(condition.errors_with_fields).to eq [{ field: :answer_value, name: "answer_value_doesnt_exist" }, { field: :goto_page_id, name: "goto_page_doesnt_exist" }]
      end
    end

    context "when the error is an unknown error" do
      let(:validation_errors) { [OpenStruct.new(name: "some_unknown_error")] }

      it "returns answer_value as a default" do
        expect(condition.errors_with_fields).to eq [{ field: :answer_value, name: "some_unknown_error" }]
      end
    end
  end

  describe "#has_errors_for_field?" do
    let(:validation_errors) { [OpenStruct.new(name: "answer_value_doesnt_exist")] }

    it "returns true when the field has an error" do
      expect(condition.has_errors_for_field?(:answer_value)).to be true
    end

    it "returns false when the field has no errors" do
      expect(condition.has_errors_for_field?(:goto_page_id)).to be false
    end
  end
end
