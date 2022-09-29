Sentry.init do |config|
  config.dsn = Settings.sentry_dsn
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.debug = true
  config.traces_sample_rate = 1.0
  config.environment = ENV["PAAS_ENVIRONMENT"] || "local"
end

# Uncomment out the below to test Sentry - this
# will raise 2 issues in Sentry

# begin
#   1 / 0
# rescue ZeroDivisionError => exception
#   Sentry.capture_exception(exception)
# end

# Sentry.capture_message("test message")
