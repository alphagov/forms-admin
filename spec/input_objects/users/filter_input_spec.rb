require "rails_helper"

RSpec.describe Users::FilterInput, type: :model do
  describe "#has_filters?" do
    context "when the name filter is set" do
      subject(:input) { described_class.new(name: "foo") }

      it "returns true" do
        expect(input.has_filters?).to be true
      end
    end

    context "when the email filter is set" do
      subject(:input) { described_class.new(email: "foo") }

      it "returns true" do
        expect(input.has_filters?).to be true
      end
    end

    context "when the organisation_id filter is set" do
      subject(:input) { described_class.new(organisation_id: 1) }

      it "returns true" do
        expect(input.has_filters?).to be true
      end
    end

    context "when no filters are set" do
      subject(:input) { described_class.new }

      it "returns false" do
        expect(input.has_filters?).to be false
      end
    end
  end
end
