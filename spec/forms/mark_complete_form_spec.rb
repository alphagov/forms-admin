require "rails_helper"

RSpec.describe Forms::MarkCompleteForm, type: :model do
  describe "validations" do
    it "is not valid if blank" do
      mark_complete_form = described_class.new(mark_complete: nil)

      expect(mark_complete_form).not_to be_valid
    end

    it "is valid if true" do
      mark_complete_form = described_class.new(mark_complete: "true")

      expect(mark_complete_form).to be_valid
    end

    it "is valid if false" do
      mark_complete_form = described_class.new(mark_complete: "false")

      expect(mark_complete_form).to be_valid
    end
  end
end
