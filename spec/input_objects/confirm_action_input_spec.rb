require "rails_helper"

RSpec.describe ConfirmActionInput, type: :model do
  describe "Confirm action input" do
    it "is invalid if blank" do
      confirm_action_input = described_class.new(confirm: "")
      confirm_action_input.validate(:confirm)

      expect(confirm_action_input.errors.full_messages_for(:confirm)).to include(
        "Confirm can't be blank",
      )
    end

    it "is invalid if value not valid" do
      confirm_action_input = described_class.new(confirm: "Foo")
      confirm_action_input.validate(:confirm)

      expect(confirm_action_input.errors.full_messages_for(:confirm)).to include(
        "Confirm is not included in the list",
      )
    end
  end
end
