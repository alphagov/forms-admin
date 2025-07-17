require "rails_helper"

describe Api::V1::ConditionResource, type: :model do
  let(:validation_errors) { [] }
  let(:condition) { described_class.new(id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3, validation_errors:) }

  describe "#database_attributes" do
    it "includes attributes for ActiveRecord Condition model" do
      expect(condition.database_attributes).to eq({
        "id" => 1,
        "routing_page_id" => 1,
        "check_page_id" => 1,
        "goto_page_id" => 3,
        "answer_value" => "Wales",
      })
    end

    it "includes ID for associated ActiveRecord Page models" do
      condition = described_class.new(id: 3, routing_page_id: 2)
      expect(condition.database_attributes).to include(
        "routing_page_id" => 2,
      )
    end

    it "does not include attributes not in the ActiveRecord Condition model" do
      expect(condition.database_attributes).not_to include(
        :validation_errors,
      )
    end
  end

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

  describe "#exit_page?" do
    it "returns true if the exit_page_markdown attribute is present and not nil" do
      exit_page_condition = build(:condition_resource, exit_page_markdown: "Exit!")
      expect(exit_page_condition.exit_page?).to be true
    end

    it "returns false if the exit_page_markdown attribute is not present" do
      not_exit_page_condition = build(:condition_resource)
      expect(not_exit_page_condition.exit_page?).to be false
    end

    it "returns false if the exit_page_markdown attribute is nil" do
      not_exit_page_condition = build(:condition_resource, exit_page_markdown: nil)
      expect(not_exit_page_condition.exit_page?).to be false
    end
  end
end
