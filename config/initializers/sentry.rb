require "active_support/parameter_filter"

require "./app/lib/email_parameter_filter_proc"

if Settings.sentry.dsn.present?
  Sentry.init do |config|
    config.dsn = Settings.sentry.dsn
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.debug = true
    config.enable_tracing = false
    config.environment = Settings.sentry.environment

    # use synchronous/blocking code for integration tests
    config.background_worker_threads = 0 if Rails.env.test?

    filter = ActiveSupport::ParameterFilter.new(
      [EmailParameterFilterProc.new(mask: Settings.sentry.filter_mask)],
      mask: Settings.sentry.filter_mask,
    )
    config.before_send = lambda do |event, _hint|
      filter.filter(event.to_hash)
    end
  end
end

# Uncomment out the below to test Sentry - this
# will raise 2 issues in Sentry

# begin
#   1 / 0
# rescue ZeroDivisionError => exception
#   Sentry.capture_exception(exception)
# end

# Sentry.capture_message("test message")
