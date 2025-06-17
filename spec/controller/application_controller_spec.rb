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
    let(:user) { create :user }
    let(:acting_as_user) { nil }

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
          allow(warden_spy).to receive_messages(
            authenticate!: true,
            authenticated?: true,
            set_user: nil,
            user: acting_as_user || user,
          )

          allow(Settings).to receive(:auth_provider).and_return(provider)

          if acting_as_user.present?
            session[:acting_as_user_id] = acting_as_user.id
            session[:original_user_id] = user.id
          end

          get :index
        end

        it "uses the #{provider} Warden strategy" do
          expect(warden_spy).to have_received(:authenticate!).with(provider.to_sym)
        end

        it "sets @current_user" do
          expect(assigns[:current_user]).to eq user
        end

        context "when acting as a user" do
          let(:acting_as_user) { create :user }

          it "sets @current_user as the acting user taken from the session" do
            expect(assigns[:current_user]).to eq acting_as_user
          end
        end
      end
    end
  end

  describe "#current_form" do
    it "returns the current form" do
      params = ActionController::Parameters.new(form_id: id)
      allow(Api::V1::FormResource).to receive(:find).with(id).and_return(form)
      allow(controller).to receive(:params).and_return(params)

      expect(controller.current_form).to eq form
    end

    it "memorizes the find form request so it doesn't have to repeat the calls" do
      params = ActionController::Parameters.new(form_id: id)
      allow(Api::V1::FormResource).to receive(:find).with(id).and_return(form)
      allow(controller).to receive(:params).and_return(params)
      controller.current_form
      controller.current_form

      expect(Api::V1::FormResource).to have_received(:find).exactly(1).times
    end
  end

  describe "analytics" do
    let(:user) { create :user }

    let(:warden_spy) do
      request.env["warden"] = instance_double(Warden::Proxy)
    end

    before do
      allow(warden_spy).to receive_messages(
        authenticate!: true,
        authenticated?: true,
        set_user: nil,
        user: user,
      )
    end

    controller do
      def redirect_action
        Current.analytics_events = [{ event_name: "test_event", properties: { test: "value" } }]
        redirect_to "/"
      end

      def normal_action
        Current.analytics_events = [{ event_name: "test_event", properties: { test: "value" } }]
        render plain: "OK"
      end

      def action_with_flash
        render plain: "OK"
      end
    end

    describe "analytics events handling" do
      let(:analytics_events) { [{ event_name: "test_event", properties: { test: "value" } }] }

      describe "set_analytics_events" do
        before do
          routes.draw do
            get "redirect_action" => "anonymous#redirect_action"
            get "normal_action" => "anonymous#normal_action"
          end
        end

        context "when response is a redirect" do
          it "sets analytics events in flash" do
            get :redirect_action
            expect(flash[:analytics_events]).to eq([{ event_name: "test_event", properties: { test: "value" } }])
          end
        end

        context "when response is not a redirect" do
          it "does not set analytics events in flash" do
            get :normal_action
            expect(flash[:analytics_events]).to be_nil
          end
        end
      end

      describe "prepare_analytics_events" do
        before do
          routes.draw do
            get "action_with_flash" => "anonymous#action_with_flash"
          end

          # Mock AnalyticsService
          allow(AnalyticsService).to receive(:add_events_from_flash)
        end

        context "when flash has analytics events" do
          it "adds events from flash to analytics service" do
            # Setup flash in the request
            request.flash[:analytics_events] = analytics_events
            request.commit_flash

            get :action_with_flash

            expect(AnalyticsService).to have_received(:add_events_from_flash).with(analytics_events)
          end
        end

        context "when flash does not have analytics events" do
          it "does not call analytics service" do
            get :action_with_flash

            expect(AnalyticsService).not_to have_received(:add_events_from_flash)
          end
        end
      end
    end
  end
end
