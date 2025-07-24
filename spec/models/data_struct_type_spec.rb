require "rails_helper"

RSpec.describe DataStructType do
  context "when converting a JSON string" do
    it "returns a DataStruct" do
      json_string = "{\"a\": \"b\", \"c\": [{ \"d\": \"e\" }, { \"f\": \"g\" }]}"
      expect(described_class.new.cast_value(json_string)).to eq(
        DataStruct.new({ a: "b", c: [DataStruct.new(d: "e"), DataStruct.new(f: "g")] }),
      )
    end
  end

  context "when converting a hash" do
    it "returns a DataStruct" do
      hash = {
        a: "b",
        c: [
          { d: "e" },
          { f: "g" },
        ],
      }
      expect(described_class.new.cast_value(hash)).to eq(
        DataStruct.new({ a: "b", c: [DataStruct.new(d: "e"), DataStruct.new(f: "g")] }),
      )
    end
  end

  context "when converting an ActiveResource" do
    it "returns a DataStruct" do
      hash = {
        a: "b",
        c: [
          { d: "e" },
          { f: "g" },
        ],
      }
      active_resource = Api::V1::PageResource.new(hash, false)
      expect(described_class.new.cast_value(active_resource)).to eq(
        DataStruct.new({ a: "b", c: [DataStruct.new(d: "e"), DataStruct.new(f: "g")] }),
      )
    end
  end
end
