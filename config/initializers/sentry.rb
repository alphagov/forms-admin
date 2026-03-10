require "active_support/parameter_filter"

require "./app/lib/email_parameter_filter_proc"

if Settings.sentry.dsn.present?
  Sentry.init do |config|
    config.dsn = Settings.sentry.dsn
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.debug = true
    config.environment = Settings.sentry.environment
    config.excluded_exceptions += %w[NotFoundError]

    filter = ActiveSupport::ParameterFilter.new(
      [EmailParameterFilterProc.new(mask: Settings.sentry.filter_mask)],
      mask: Settings.sentry.filter_mask,
    )

    config.before_send = lambda do |event, _hint|
      if event.exception && event.exception.values.present?
        event.exception.values.each do |exception| # rubocop:disable Style/HashEachMethods
          exception.value = filter.filter_param(nil, exception.value)
        end
      end
      if event.extra
        event.extra = filter.filter(event.extra)
      end
      if event.user
        event.user = filter.filter(event.user)
      end
      if event.contexts
        event.contexts = filter.filter(event.contexts)
      end

      event
    end

    config.before_breadcrumb = lambda do |breadcrumb, _hint|
      if breadcrumb.data
        breadcrumb.data = filter.filter(breadcrumb.data)
      end

      breadcrumb
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
