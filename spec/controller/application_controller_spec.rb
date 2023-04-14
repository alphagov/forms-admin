require "rails_helper"

describe ApplicationController, type: :controller do
  subject(:application_controller) { described_class.new }

  describe "#user_ip" do
    [
      ["", nil],
      ["127.0.0.1", "127.0.0.1"],
      ["127.0.0.1, 192.168.0.128", "127.0.0.1"],
      ["185.93.3.65, 15.158.44.215, 10.0.1.94", "185.93.3.65"],
      ["    185.93.3.65, 15.158.44.215, 10.0.1.94", nil],
      ["invalid value, 192.168.0.128", nil],
      ["192.168.0.128.123.2981", nil],
      ["2001:db8::, 2001:db8:3333:4444:CCCC:DDDD:EEEE:FFFF, ::1234:5678", "2001:db8::"],
      [",,,,,,,,,,,,,,,,,,,,,,,,", nil],
    ].each do |value, expected|
      it "returns #{expected.inspect} when given forwarded_for #{value.inspect}" do
        expect(application_controller.user_ip(value)).to eq(expected)
      end
    end
  end

  controller do
    def index
      render status: :ok, json: {}
    end
  end

  context "when authenticating a user" do
    let(:user) { build :user }

    let(:warden_spy) do
      request.env["warden"] = instance_double(Warden::Proxy)
    end

    %w[
      auth0
      basic_auth
      gds_sso
    ].each do |provider|
      context "when #{provider} auth is enabled" do
        before do
          allow(warden_spy).to receive(:authenticate!).and_return(true)
          allow(controller).to receive(:current_user).and_return(user)

          allow(Settings).to receive(:auth_provider).and_return(provider)

          get :index
        end

        it "uses the #{provider} Warden strategy" do
          expect(warden_spy).to have_received(:authenticate!).with(provider.to_sym)
        end

        it "sets @current_user" do
          expect(assigns[:current_user]).to eq user
        end
      end
    end
  end
end
