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
    it "invokes Signon authentication when basic auth is not enabled" do
      signon_user = User.new(name: "tester", organisation_slug: "testing")

      # Mock GDS SSO
      allow(request.env["warden"]).to receive(:authenticate!).and_return(true)
      expect(request.env["warden"]).to receive(:authenticate!)
      allow(controller).to receive(:current_user).and_return(signon_user)

      get :index

      expect(assigns[:current_user].name).to be signon_user.name
      expect(assigns[:current_user].email).to be signon_user.email
      expect(assigns[:current_user].organisation_slug).to be signon_user.organisation_slug
    end

    it "invokes basic auth when it is enabled" do
      # Mock basic auth settings
      test_user_name = "tester"
      test_password = "password"
      basic_auth_double = object_double("basic_auth_double", enabled: true, username: test_user_name, password: test_password)
      allow(Settings).to receive(:basic_auth).and_return(basic_auth_double)

      # Mock warden manager and config
      warden_config_double = instance_double(Warden::Config, intercept_401: false)
      warden_manager_double = instance_double(Warden::Manager, config: warden_config_double)
      allow(request.env["warden"]).to receive(:manager).and_return(warden_manager_double)
      expect(warden_config_double).to receive(:intercept_401=).with(false)
      allow(controller).to receive(:http_basic_authenticate_or_request_with).and_return(true)
      expect(controller).to receive(:http_basic_authenticate_or_request_with)

      get :index

      expect(assigns[:current_user].name).to eq(test_user_name)
      expect(assigns[:current_user].email).to eq("#{test_user_name}@example.com")
      expect(assigns[:current_user].organisation_slug).to eq("government-digital-service")
    end
  end
end
