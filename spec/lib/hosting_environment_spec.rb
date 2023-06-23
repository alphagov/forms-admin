require "rails_helper"

RSpec.describe HostingEnvironment do
  describe ".test_environment?" do
    let(:paas_environment) { nil }
    let(:rails_env) { nil }

    around do |example|
      ClimateControl.modify PAAS_ENVIRONMENT: paas_environment do
        example.run
      end
    end

    context "with PAAS_ENVIRONMENT set to dev" do
      let(:paas_environment) { "dev" }

      it "returns true" do
        expect(described_class.test_environment?).to be(true)
      end
    end

    context "with PAAS_ENVIRONMENT set to production" do
      let(:paas_environment) { "production" }

      it "returns true" do
        expect(described_class.test_environment?).to be(false)
      end
    end

    context "when in local development" do
      before { allow(Rails.env).to receive(:production?).and_return(false) }

      it "returns true" do
        expect(described_class.test_environment?).to be(true)
      end
    end

    context "when in production" do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it "returns false" do
        expect(described_class.test_environment?).to be(false)
      end
    end
  end

  describe "#friendly_environment_name" do
    before do
      allow(described_class).to receive(:environment_name).and_return(environment_name)
      allow(described_class).to receive(:local_development?).and_return(is_local_development)
    end

    [
      { environment_name: "unknown_environment", is_local_development: true, expected_key: "local" },
      { environment_name: "dev", is_local_development: false, expected_key: "dev" },
      { environment_name: "production", is_local_development: false, expected_key: "production" },
      { environment_name: "aws-staging", is_local_development: false, expected_key: "aws-staging" },
      { environment_name: "aws-user-research", is_local_development: false, expected_key: "aws-user-research" },
    ].each do |scenario|
      context "with environment name set to '#{scenario[:environment_name]}' and is_local_development set to '#{scenario[:is_local_development]}" do
        let(:environment_name) { scenario[:environment_name] }
        let(:is_local_development) { scenario[:is_local_development] }

        it "returns the correct translation" do
          expect(described_class.friendly_environment_name).to eq(I18n.t("environment_names.#{scenario[:expected_key]}"))
        end
      end
    end

    context "with environment name set to an unknown value and rails_env set to production" do
      let(:environment_name) { "some_unknown_environemnt_string" }
      let(:is_local_development) { false }

      it "returns the environment name as default text" do
        expect(described_class.friendly_environment_name).to eq(environment_name)
      end
    end
  end
end
