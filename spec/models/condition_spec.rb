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
end
