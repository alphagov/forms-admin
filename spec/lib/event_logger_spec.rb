require "rails_helper"
require_relative "../../app/lib/event_logger"

RSpec.describe EventLogger do
  before do
    logger = LoggerMock.new
    tagged_logging = ActiveSupport::TaggedLogging.new(logger)
    allow(Rails).to receive(:logger).and_return(tagged_logging)
  end

  it "logs an event" do
    described_class.log({ event: "testing", test: true })

    expect(Rails.logger.logged(:info)).to eq [
      '{"event":"testing","test":true}',
    ]
  end
end
