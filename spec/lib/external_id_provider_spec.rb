require "rails_helper"

RSpec.describe ExternalIdProvider do
  describe ".generate_id" do
    it "returns a string" do
      expect(described_class.generate_id).to be_a(String)
    end

    it "returns a string of length 8" do
      expect(described_class.generate_id.length).to eq(8)
    end
  end

  describe ".generate_unique_id_for" do
    let(:record_class) { class_double(ActiveRecord::Base) }

    it "raises ArgumentError if the record_class is not an ActiveRecord?" do
      expect {
        described_class.generate_unique_id_for(Object.new)
      }.to raise_error(ArgumentError, /must be an ActiveRecord class/)
    end

    it "returns the first generated ID when it is unique" do
      allow(described_class).to receive(:generate_id).and_return("a-unique-id")
      allow(record_class).to receive(:exists?).with(external_id: "a-unique-id").and_return(false)

      expect(described_class.generate_unique_id_for(record_class)).to eq("a-unique-id")
      expect(record_class).to have_received(:exists?).with(external_id: "a-unique-id")
    end

    it "retries until a unique ID is found" do
      allow(described_class).to receive(:generate_id).and_return("duplicate", "a-unique-id")
      allow(record_class).to receive(:exists?).with(external_id: "duplicate").and_return(true)
      allow(record_class).to receive(:exists?).with(external_id: "a-unique-id").and_return(false)

      expect(described_class.generate_unique_id_for(record_class)).to eq("a-unique-id")
      expect(record_class).to have_received(:exists?).with(external_id: "duplicate")
      expect(record_class).to have_received(:exists?).with(external_id: "a-unique-id")
    end

    it "raises an error when max retries reached" do
      allow(described_class).to receive(:generate_id).and_return(Faker::Alphanumeric.alpha)
      allow(record_class).to receive(:exists?).and_return(true)

      expect {
        described_class.generate_unique_id_for(record_class)
      }.to raise_error(StandardError, "Unable to generate unique external_id for #{record_class}")

      expect(record_class).to have_received(:exists?).exactly(5).times
    end
  end
end
