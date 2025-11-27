require "rails_helper"

describe ErrorSummaryPresenter do
  subject(:error_summary_presenter) { described_class.new(errors) }

  let(:form) { build :form }

  let(:errors) { ActiveModel::Errors.new(form) }

  describe "#formatted_error_messages" do
    context "when there are no errors" do
      it "returns an empty array" do
        expect(error_summary_presenter.formatted_error_messages).to eq []
      end
    end

    context "when there are errors" do
      before do
        errors.add(:name, "Can't be blank")
        errors.add(:privacy_policy_url, "Wrong format")
      end

      it "returns an array of formatted errors" do
        expect(error_summary_presenter.formatted_error_messages).to eq [[:name, "Can't be blank"], [:privacy_policy_url, "Wrong format"]]
      end
    end

    context "when a field has multiple errors" do
      before do
        errors.add(:name, "Can't be blank")
        errors.add(:name, "Too long")
        errors.add(:privacy_policy_url, "Wrong format")
        errors.add(:privacy_policy_url, "Can't be blank")
      end

      it "only includes the first error for each field" do
        expect(error_summary_presenter.formatted_error_messages).to eq [[:name, "Can't be blank"], [:privacy_policy_url, "Wrong format"]]
      end
    end

    context "when a field has a custom URL specified" do
      before do
        errors.add(:name, "Can't be blank")
        errors.add(:privacy_policy_url, "Wrong format", url: "https://gov.uk/forms")
      end

      it "includes the custom URL in the formatted result" do
        expect(error_summary_presenter.formatted_error_messages).to eq [[:name, "Can't be blank"], [:privacy_policy_url, "Wrong format", "https://gov.uk/forms"]]
      end
    end
  end
end
