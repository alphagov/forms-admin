require "rails_helper"

RSpec.describe TextInputHelper, type: :helper do
  describe "#strip_carriage_returns" do
    it "removes carriage returns" do
      input = "some\r\ntext\r\with\nnew lines\r\n"
      helper.strip_carriage_returns!(input)

      expect(input).to eq("some\ntext\nwith\nnew lines\n")
    end

    it "does not error if input is nil" do
      expect {
        helper.strip_carriage_returns!(nil)
      }.not_to raise_error
    end
  end
end
