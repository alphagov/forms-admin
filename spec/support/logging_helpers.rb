module LoggingHelpers
  def self.included(base)
    base.class_eval do
      let(:log_output) { StringIO.new }
      let(:logger) { ActiveSupport::Logger.new(log_output) }
      let(:log_lines) { parse_log_lines(log_output) }
      let(:log_line) { log_lines.first }

      prepend_before do
        allow(Lograge).to receive(:logger).and_return(logger)
      end
    end
  end

  def parse_log_lines(logger_output)
    logger_output.string.split("\n").map { |line| JSON.parse(line) }
  end
end

RSpec.configure do |config|
  config.include LoggingHelpers, :capture_logging
end
