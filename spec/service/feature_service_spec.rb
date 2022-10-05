require "rails_helper"

describe FeatureService do
  describe ".enabled?" do
    context "when eature is enabled" do
      before do
        Settings.features[:some_feature] = true
      end

      it "returns true" do
        response = described_class.enabled?(:some_feature)

        expect(response).to be_truthy
      end
    end

    context "when feature is disabled" do
      before do
        Settings.features[:some_feature] = false
      end

      it "returns false" do
        response = described_class.enabled?(:some_feature)

        expect(response).to be_falsey
      end
    end

    context "when empty features" do
      before do
        allow(Settings).to receive(:features).and_return(nil)
      end

      it "returns false" do
        response = described_class.enabled?(:some_feature)

        expect(response).to be_falsey
      end
    end

    context "when nested features" do
      before do
        Settings.features[:some] = OpenStruct.new(nested_feature: true)
      end

      it "returns true" do
        response = described_class.enabled?("some.nested_feature")

        expect(response).to be_truthy
      end
    end
  end
end
