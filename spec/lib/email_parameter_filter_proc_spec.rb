require "rails_helper"

require_relative "../../app/lib/email_parameter_filter_proc"

RSpec.describe EmailParameterFilterProc do
  let(:email_parameter_filter) do
    ActiveSupport::ParameterFilter.new(
      [described_class.new],
    )
  end

  it "filters email address from strings in hashes" do
    expect(email_parameter_filter.filter({ email: "test@example.com" }))
      .to eq({ email: "[FILTERED]" })
  end

  it "leaves value unchanged if it is not a string" do
    expect(email_parameter_filter.filter({ symbol: :test }))
      .to eq({ symbol: :test })
  end

  it "filters all email addresses from strings" do
    expect(email_parameter_filter.filter_param("", "lorem ipsum example@filter.test dolor sit"))
      .to eq("lorem ipsum [FILTERED] dolor sit")
  end

  context "when a custom mask is provided" do
    let(:mask) { "********" }

    let(:email_parameter_filter) do
      ActiveSupport::ParameterFilter.new(
        [described_class.new(mask:)], mask:
      )
    end

    it "replaces email addresses with the custom mask" do
      expect(email_parameter_filter.filter_param("", "hello test@gov.uk.example"))
        .to eq("hello ********")
    end
  end
end
