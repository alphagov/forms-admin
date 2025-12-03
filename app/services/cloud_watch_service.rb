class CloudWatchService
  REGION = "eu-west-2".freeze
  A_WEEK = 604_800
  A_DAY = 86_400
  METRICS_NAMESPACE = "Forms".freeze

  def initialize(form_id)
    @form_id = form_id
  end

  def past_week_metrics_data
    return nil unless Settings.cloudwatch_metrics_enabled

    weekly_submissions = week_submissions
    weekly_starts = week_starts

    {
      weekly_submissions:,
      weekly_starts:,
    }
  rescue Aws::CloudWatch::Errors::ServiceError,
         Aws::Errors::MissingCredentialsError => e

    Sentry.capture_exception(e)
    nil
  end

  def daily_metrics_data(start_time)
    {
      submissions: daily_submissions(start_time),
      starts: daily_starts(start_time),
    }
  rescue Aws::CloudWatch::Errors::ServiceError,
         Aws::Errors::MissingCredentialsError => e

    Sentry.capture_exception(e)
    nil
  end

private

  def week_submissions
    cloudwatch_client = Aws::CloudWatch::Client.new(region: REGION)

    response = cloudwatch_client.get_metric_statistics({
      metric_name: "Submitted",
      namespace: METRICS_NAMESPACE,
      dimensions: [
        environment_dimension,
        form_id_dimension,
      ],
      start_time: start_of_today - 7.days,
      end_time: start_of_today,
      period: A_WEEK,
      statistics: %w[Sum],
      unit: "Count",
    })

    response.datapoints[0]&.sum.to_i || 0
  end

  def week_starts
    cloudwatch_client = Aws::CloudWatch::Client.new(region: REGION)

    response = cloudwatch_client.get_metric_statistics({
      metric_name: "Started",
      namespace: METRICS_NAMESPACE,
      dimensions: [
        environment_dimension,
        form_id_dimension,
      ],
      start_time: start_of_today - 7.days,
      end_time: start_of_today,
      period: A_WEEK,
      statistics: %w[Sum],
      unit: "Count",
    })

    response.datapoints[0]&.sum.to_i || 0
  end

  def daily_submissions(start_time)
    cloudwatch_client = Aws::CloudWatch::Client.new(region: REGION)

    response = cloudwatch_client.get_metric_statistics({
      metric_name: "Submitted",
      namespace: METRICS_NAMESPACE,
      dimensions: [
        environment_dimension,
        form_id_dimension,
      ],
      start_time: start_time,
      end_time: start_of_today,
      period: A_DAY,
      statistics: %w[Sum],
      unit: "Count",
    })

    datapoints_to_hash_by_date(response.datapoints)
  end

  def daily_starts(start_time)
    cloudwatch_client = Aws::CloudWatch::Client.new(region: REGION)

    response = cloudwatch_client.get_metric_statistics({
      metric_name: "Started",
      namespace: METRICS_NAMESPACE,
      dimensions: [
        environment_dimension,
        form_id_dimension,
      ],
      start_time: start_time,
      end_time: start_of_today,
      period: A_DAY,
      statistics: %w[Sum],
      unit: "Count",
    })

    datapoints_to_hash_by_date(response.datapoints)
  end

  def datapoints_to_hash_by_date(datapoints)
    datapoints.sort_by(&:timestamp).each_with_object({}) do |item, acc|
      key = item[:timestamp].to_date.iso8601
      acc[key] = item[:sum]
    end
  end

  def environment_dimension
    {
      name: "Environment",
      value: Settings.forms_env.downcase,
    }
  end

  def form_id_dimension
    {
      name: "FormId",
      value: @form_id.to_s,
    }
  end

  def start_of_today
    Time.zone.now.midnight
  end
end
