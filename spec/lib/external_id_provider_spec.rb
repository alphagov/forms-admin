require "rails_helper"

RSpec.describe ExternalIdProvider do
  describe "#generate_id" do
    it "returns a string" do
      expect(described_class.generate_id).to be_a(String)
    end

    it "returns a string of length 8" do
      expect(described_class.generate_id.length).to eq(8)
    end
  end
end
