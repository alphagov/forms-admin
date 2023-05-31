require "rails_helper"

describe Condition do
  let(:validation_errors) { [] }
  let(:condition) { described_class.new(id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3, validation_errors:) }

  describe "#errors_with_fields" do
    context "when the error is a known error" do
      let(:validation_errors) { [OpenStruct.new(name: "answer_value_doesnt_exist"), OpenStruct.new(name: "goto_page_doesnt_exist"), OpenStruct.new(name: "cannot_have_goto_page_before_routing_page"), OpenStruct.new(name: "cannot_route_to_next_page")] }

      it "returns the correct values for each error type" do
        expect(condition.errors_with_fields).to eq [{ field: :answer_value, name: "answer_value_doesnt_exist" }, { field: :goto_page_id, name: "goto_page_doesnt_exist" }, { field: :goto_page_id, name: "cannot_have_goto_page_before_routing_page" }, { field: :goto_page_id, name: "cannot_route_to_next_page" }]
      end
    end

    context "when the error is an unknown error" do
      let(:validation_errors) { [OpenStruct.new(name: "some_unknown_error")] }

      it "returns answer_value as a default" do
        expect(condition.errors_with_fields).to eq [{ field: :answer_value, name: "some_unknown_error" }]
      end
    end
  end
end
