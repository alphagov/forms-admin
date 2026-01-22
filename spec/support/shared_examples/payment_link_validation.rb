RSpec.shared_examples "a payment link validator" do
  context "when given a Pay URL" do
    it "validates succesfully" do
      model.send("#{attribute}=", "https://www.gov.uk/payments/test-org/test-service")

      expect(model).to be_valid
    end
  end

  context "when given a Pay URL without 'www' prefix" do
    it "validates succesfully" do
      model.send("#{attribute}=", "https://gov.uk/payments/test-org/test-service")

      expect(model).to be_valid
    end
  end

  context "when given a value that is not a valid URI" do
    it "returns a validation error" do
      model.send("#{attribute}=", "https://gov.uk/payments/ test-org /test-service")

      expect(model).to be_invalid
      expect(model.errors.map(&:type)).to include :url
    end
  end
end
