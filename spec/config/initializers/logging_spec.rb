require "rails_helper"

require_relative "../../../app/lib/json_log_formatter"

describe "Logging initializer" do
  it "configures log level to be info" do
    expect(Rails.application.config.log_level).to eq :info
  end

  it "configures log formatter to use JSON" do
    expect(Rails.application.config.log_formatter).to be_instance_of JsonLogFormatter
  end

  it "configures lograge to be enabled" do
    expect(Rails.application.config.lograge.enabled).to eq true
  end

  it "configures lograge formatter to use JSON" do
    expect(Rails.application.config.lograge.formatter).to be_instance_of Lograge::Formatters::Json
  end

  it "configures lograge custom options" do
    expect(Rails.application.config.lograge.custom_options).to respond_to :call
  end

  describe "lograge custom options" do
    let(:lograge_custom_options) do
      Rails.application.config.lograge.custom_options
    end

    let(:event) do
      OpenStruct.new(
        payload: {
          host: "foo.com",
          user_id: 1,
          user_email: Faker::Internet.email,
          user_organisation_slug: "gds",
          user_ip: Faker::Internet.ip_v4_address,
          request_id: Faker::Internet.uuid,
          form_id: 11,
          page_id: 111,
        },
      )
    end

    it "adds extra details from event payload to the log event" do
      expect(lograge_custom_options.call(event)).to eq event.payload
    end

    it "does not add all information from event payload" do
      event.payload[:extra] = "foobar"
      expect(lograge_custom_options.call(event)).not_to include :extra
    end

    %i[form_id page_id exception].each do |key|
      it "does not add #{key} if it is not in the event payload" do
        event.payload.delete(key)
        expect(lograge_custom_options.call(event)).not_to include key
      end
    end

    it "adds exception if it is in the event payload" do
      event = OpenStruct.new(payload: { exception: "FooBar error" })
      expect(lograge_custom_options.call(event)).to include(exception: "FooBar error")
    end
  end

  context "when loading" do
    let(:env) { "test" }

    before do
      allow(Rails).to receive(:env).and_return(
        ActiveSupport::EnvironmentInquirer.new(env),
      )
      allow(Rails.application).to receive(:configure)

      load File.realpath("../../../config/initializers/logging.rb", __dir__)
    end

    describe "in the development environment" do
      let(:env) { "development" }

      it "does not configure logging" do
        expect(Rails.application).not_to have_received :configure
      end
    end

    describe "in the production environment" do
      let(:env) { "production" }

      it "does configure logging" do
        expect(Rails.application).to have_received :configure
      end
    end
  end
end
