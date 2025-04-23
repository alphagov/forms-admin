module LoggingHelpers
  def log_lines(logger_output)
    logger_output.string.split("\n").map { |line| JSON.parse(line) }
  end
end

RSpec.configure do |config|
  config.include LoggingHelpers
end
