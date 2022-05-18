Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = %i[sentry_logger http_logger]
  config.debug = true
  config.traces_sample_rate = 1.0
end

# Uncomment out the below to test Sentry - this
# will raise 2 issues in Sentry

# begin
#   1 / 0
# rescue ZeroDivisionError => exception
#   Sentry.capture_exception(exception)
# end

# Sentry.capture_message("test message")
