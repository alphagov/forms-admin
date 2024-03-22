require "rails_helper"

describe ApplicationController, type: :controller do
  subject(:application_controller) { described_class.new }

  let(:id) { 1 }
  let(:form) { build :form }

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

  describe "#clear_draft_questions_data" do
    let(:user) { create(:user) }

    it "destroys draft questions when user is present" do
      allow(controller).to receive(:current_user).and_return(user)
      create_list(:draft_question, 3, user:)

      controller.send(:clear_draft_questions_data)

      expect(user.draft_questions.count).to eq(0)
    end

    it "does not raise an error when draft question and user are not present" do
      expect { controller.send(:clear_draft_questions_data) }.not_to raise_exception
    end
  end

  describe "#current_form" do
    it "returns the current form" do
      params = ActionController::Parameters.new(form_id: id)
      allow(Form).to receive(:find).with(id).and_return(form)
      allow(controller).to receive(:params).and_return(params)

      expect(controller.current_form).to eq form
    end

    it "memorizes the find form request so it doesn't have to repeat the calls" do
      params = ActionController::Parameters.new(form_id: id)
      allow(Form).to receive(:find).with(id).and_return(form)
      allow(controller).to receive(:params).and_return(params)
      controller.current_form
      controller.current_form

      expect(Form).to have_received(:find).exactly(1).times
    end
  end

  describe "#current_live_form" do
    it "returns the current live form" do
      params = ActionController::Parameters.new(form_id: id)
      allow(Form).to receive(:find_live).with(id).and_return(form)
      allow(controller).to receive(:params).and_return(params)

      expect(controller.current_live_form).to eq form
    end

    it "memorizes the find form request so it doesn't have to repeat the calls" do
      params = ActionController::Parameters.new(form_id: id)
      allow(Form).to receive(:find_live).with(id).and_return(form)
      allow(controller).to receive(:params).and_return(params)
      controller.current_live_form
      controller.current_live_form

      expect(Form).to have_received(:find_live).exactly(1).times
    end
  end
end
