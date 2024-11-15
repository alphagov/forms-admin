require "rails_helper"

require "omniauth/strategies/username_and_password"

RSpec.describe OmniAuth::Strategies::UsernameAndPassword, type: :request do
  let(:app) do
    Rack::Builder.new { |b|
      b.use Rack::Session::Cookie, secret: "abc1234" * 10
      b.use OmniAuth::Strategies::UsernameAndPassword do |options| # rubocop:disable RSpec/DescribedClass
        options[:username] = "tester"
        options[:password] = "secret"
        options[:email_domain] = "example.com"
      end
      b.run do |env|
        if !env.include?("omniauth.strategy")
          [404, {}, ["Not Found"]]
        else
          [200, {}, %w[OK]]
        end
      end
    }.to_app
  end

  let(:auth_hash) { request.env["omniauth.auth"] }

  describe "request phase" do
    before do
      post "/auth/usernameandpassword"
    end

    it "renders a form" do
      expect(response).to have_http_status 200
      expect(response.body).to include "<form"
    end

    describe "form" do
      let(:form) { rendered.find("form") }
      let(:rendered) { Capybara.string(response.body) }

      it "has a username field" do
        expect(form).to have_field "Username"
      end

      it "has a password field" do
        expect(form).to have_field "Password", type: :password
      end

      it "has a submit button" do
        expect(form).to have_button "Continue", type: "submit"
      end

      it "posts the credentials to the callback URL" do
        expect(form["method"]).to eq "post"
        expect(form["action"]).to eq "/auth/usernameandpassword/callback"
      end
    end
  end

  describe "callback phase" do
    context "when the given username and password matches the expected username and password" do
      before do
        post "/auth/usernameandpassword/callback", params: { username: "tester", password: "secret" }
      end

      it "calls the app after processing the request" do
        expect(response).to have_http_status :ok
        expect(response.body).to eq "OK"
      end

      it "sets the username in the auth hash" do
        expect(auth_hash.info.name).to eq "tester"
      end

      it "sets the email in the auth hash" do
        expect(auth_hash.info.email).to eq "tester@example.com"
      end

      it "sets the uid to the username" do
        expect(auth_hash.uid).to eq "usernameandpassword|tester"
      end
    end

    context "when the given username and password does not match the expected username and password" do
      before do
        allow(OmniAuth.config.on_failure).to receive(:call).and_call_original

        post "/auth/usernameandpassword/callback", params: { username: "help", password: "" }
      end

      it "fails" do
        expect(OmniAuth.config.on_failure).to have_received(:call)
        expect(request.env["omniauth.error.type"]).to eq :invalid_credentials
      end

      it "does not authenticate the user" do
        expect(auth_hash).to be_nil
      end
    end
  end
end
