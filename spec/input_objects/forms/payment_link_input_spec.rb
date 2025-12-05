require "rails_helper"

RSpec.describe Forms::PaymentLinkInput, type: :model do
  describe "Payment URL" do
    let(:form) do
      build(:form, :live)
    end

    it_behaves_like "a payment link validator" do
      let(:model) { described_class.new }
      let(:attribute) { :payment_url }
    end

    context "when given a blank payment_url" do
      it "validates successfully" do
        payment_link_input = described_class.new(form:, payment_url: "")

        expect(payment_link_input).to be_valid
      end
    end

    context "when given a value that is not a url" do
      it "returns a validation error" do
        payment_link_input = described_class.new(form:, payment_url: "not-a-url")

        payment_link_input.validate(:payment_url)

        expect(payment_link_input.errors.full_messages_for(:payment_url)).to include(
          "Payment url Enter a link in the correct format, like https://www.gov.uk/payments/your-payment-link",
        )
      end
    end
  end
end
