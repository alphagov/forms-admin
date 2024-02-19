require "rails_helper"

RSpec.describe Forms::PaymentLinkForm, type: :model do
  describe "Payment URL" do
    let(:form) do
      build(:form, :live)
    end

    context "when given a Pay URL" do
      it "validates succesfully" do
        payment_link_form = described_class.new(form:, payment_url: "https://www.gov.uk/payments/test-org/test-service")

        expect(payment_link_form).to be_valid
      end
    end

    context "when given a blank payment_url" do
      it "validates successfully" do
        payment_link_form = described_class.new(form:, payment_url: "")

        expect(payment_link_form).to be_valid
      end
    end

    context "when given a value that is not a url" do
      it "returns a validation error" do
        payment_link_form = described_class.new(form:, payment_url: "not-a-url")

        payment_link_form.validate(:payment_url)

        expect(payment_link_form.errors.full_messages_for(:payment_url)).to include(
          "Payment url Enter a link in the correct format, like https://www.gov.uk/payments/organisation/service",
        )
      end
    end

    context "when given a value that does not start with GOV.UK Pay formatting" do
      it "returns a validation error" do
        payment_link_form = described_class.new(form:, payment_url: "http://www.example.com")

        payment_link_form.validate(:payment_url)

        expect(payment_link_form.errors.full_messages_for(:payment_url)).to include(
          "Payment url Enter a link in the correct format, like https://www.gov.uk/payments/organisation/service",
        )
      end
    end
  end
end
