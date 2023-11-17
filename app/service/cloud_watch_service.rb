class CloudWatchService
  REGION = "eu-west-2".freeze
  A_WEEK = 604_800

  class MetricsDisabledError < StandardError; end

  def self.week_submissions(form_id:)
    raise MetricsDisabledError unless Settings.cloudwatch_metrics_enabled

    cloudwatch_client = Aws::CloudWatch::Client.new(region: REGION)

    response = cloudwatch_client.get_metric_statistics({
      metric_name: "submitted",
      namespace: metric_namespace.to_s,
      dimensions: [
        {
          name: "form_id",
          value: form_id.to_s,
        },
      ],
      start_time: start_of_today - 7.days,
      end_time: start_of_today,
      period: A_WEEK,
      statistics: %w[Sum],
      unit: "Count",
    })

    response.datapoints[0]&.sum.to_i || 0
  end

  def self.week_starts(form_id:)
    raise MetricsDisabledError unless Settings.cloudwatch_metrics_enabled

    cloudwatch_client = Aws::CloudWatch::Client.new(region: REGION)

    response = cloudwatch_client.get_metric_statistics({
      metric_name: "started",
      namespace: metric_namespace.to_s,
      dimensions: [
        {
          name: "form_id",
          value: form_id.to_s,
        },
      ],
      start_time: start_of_today - 7.days,
      end_time: start_of_today,
      period: A_WEEK,
      statistics: %w[Sum],
      unit: "Count",
    })

    response.datapoints[0]&.sum.to_i || 0
  end

  def self.metric_namespace
    "forms/#{Settings.forms_env}".downcase
  end

  def self.start_of_today
    Time.zone.now.midnight
  end
end
