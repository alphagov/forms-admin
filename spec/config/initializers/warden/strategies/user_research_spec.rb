require "rails_helper"

RSpec.describe Warden::Strategies[:user_research] do
  subject(:strategy) { described_class.new(env) }

  let(:env) do
    {
      "omniauth.auth" => instance_double(OmniAuth::AuthHash),
    }
  end

  before do
    allow(Settings).to receive_messages(auth_provider: "user_research", forms_env: "user-research")
  end

  describe "#valid?" do
    it { is_expected.to be_valid }

    context "when user_research auth provider is not selected" do
      before do
        allow(Settings).to receive(:auth_provider).and_return("auth0")
      end

      it { is_expected.not_to be_valid }
    end

    context "when app is not in the user-research environment" do
      before do
        allow(Settings).to receive(:forms_env).and_return("production")
      end

      it { is_expected.not_to be_valid }
    end

    context "when OmniAuth has not successfully requested credentials" do
      let(:env) { { "omniauth.auth" => nil } }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#authenticate!" do
    let(:env) do
      {
        "omniauth.auth" => OmniAuth::AuthHash.new({
          uid: "user-research|tester",
          provider: "user-research",
          info: {
            name: "tester",
            email: "tester@example.gov.uk",
          },
        }),
        "omniauth.strategy" => OpenStruct.new(
          name: "user-research",
        ),
      }
    end

    before do
      strategy.authenticate!
    end

    it { is_expected.to be_successful }
  end
end
