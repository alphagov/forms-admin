require "rails_helper"

describe Page do
  describe "#convert_is_optional_to_boolean" do
    context "when a question is optional" do
      it "set the model attribute to true" do
        page = described_class.new(is_optional: "true")
        page.convert_is_optional_to_boolean
        expect(page.is_optional).to be true
      end
    end

    context "when a question is required" do
      it "clears the model attribute is false" do
        page = described_class.new(is_optional: "false")
        page.convert_is_optional_to_boolean
        expect(page.is_optional).to be nil
      end

      it "clears the model attribute if value is 0" do
        page = described_class.new(is_optional: "0")
        page.convert_is_optional_to_boolean
        expect(page.is_optional).to be nil
      end

      it "clears the model attribute if its not set to 'true'" do
        page = described_class.new(is_optional: "something")
        page.convert_is_optional_to_boolean
        expect(page.is_optional).to be nil
      end
    end
  end
end
