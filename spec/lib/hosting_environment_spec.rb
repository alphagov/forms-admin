require "rails_helper"

RSpec.describe HostingEnvironment do
  describe "#environment_name" do
    let(:settings__forms_env) { nil }

    before do
      allow(Settings).to receive(:forms_env).and_return(settings__forms_env)
    end

    context "when forms_env is set" do
      let(:settings__forms_env) { "dev" }

      it "returns the value of forms_env" do
        expect(described_class.environment_name).to eq "dev"
      end
    end

    context "when forms_env is not set" do
      it "returns unknown_environment" do
        expect(described_class.environment_name).to eq nil
      end
    end
  end

  describe ".test_environment?" do
    let(:settings__forms_env) { nil }

    before do
      allow(Settings).to receive(:forms_env).and_return(settings__forms_env)
    end

    context "with forms_env set to dev" do
      let(:settings__forms_env) { "dev" }

      it "returns true" do
        expect(described_class.test_environment?).to be(true)
      end
    end

    context "with forms_env set to paas_dev" do
      let(:settings__forms_env) { "paas_dev" }

      it "returns true" do
        expect(described_class.test_environment?).to be(true)
      end
    end

    context "with forms_env set to production" do
      let(:settings__forms_env) { "production" }

      it "returns true" do
        expect(described_class.test_environment?).to be(false)
      end
    end

    context "when in local development" do
      let(:settings__forms_env) { "local" }

      it "returns true" do
        expect(described_class.test_environment?).to be(true)
      end
    end

    context "when in production" do
      it "returns false" do
        allow(Rails).to receive(:env).and_return(OpenStruct.new(production?: true))
        expect(described_class.test_environment?).to be(false)
      end
    end
  end

  describe "#friendly_environment_name" do
    before do
      allow(described_class).to receive(:environment_name).and_return(environment_name)
    end

    [
      { environment_name: "local", expected_key: "local" },
      { environment_name: "dev", expected_key: "dev" },
      { environment_name: "paas_production", expected_key: "production" },
      { environment_name: "paas_staging", expected_key: "staging" },
      { environment_name: "user-research", expected_key: "user-research" },
    ].each do |scenario|
      context "with environment name set to '#{scenario[:environment_name]}'" do
        let(:environment_name) { scenario[:environment_name] }

        it "returns the correct translation" do
          expect(described_class.friendly_environment_name).to eq(I18n.t("environment_names.#{scenario[:expected_key]}"))
        end
      end
    end

    context "with environment name set to an unknown value" do
      let(:environment_name) { "some_unknown_environemnt_string" }

      it "returns the environment name as default text" do
        expect(described_class.friendly_environment_name).to eq(environment_name)
      end
    end
  end
end
