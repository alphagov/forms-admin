# Based on ActiveSupport::LogSubscriber::TestHelper::MockLogger,
# but with support for formatters/tagging.
# https://github.com/rails/rails/blob/e88857bbb9d4e1dd64555c34541301870de4a45b/activesupport/lib/active_support/log_subscriber/test_helper.rb

class LoggerMock
  attr_reader :formatter

  def initialize
    @formatter = proc { |_severity, _time, _progname, msg| msg }
    @logged = Hash.new { |h, k| h[k] = [] }
  end

  def logged(level)
    @logged[level].compact.map { |l| l.to_s.strip }
  end

  def method_missing(level, msg = nil) # rubocop:disable Style/MissingRespondToMissing
    @logged[level] << @formatter.call(level, Time.zone.now, "test", msg)
  end
end
