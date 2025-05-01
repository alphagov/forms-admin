class CloudWatchService
  REGION = "eu-west-2".freeze
  A_WEEK = 604_800
  METRICS_NAMESPACE = "Forms".freeze

  def self.week_submissions(form_id:)
    cloudwatch_client = Aws::CloudWatch::Client.new(region: REGION)

    response = cloudwatch_client.get_metric_statistics({
      metric_name: "Submitted",
      namespace: METRICS_NAMESPACE,
      dimensions: [
        environment_dimension,
        form_id_dimension(form_id),
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
    cloudwatch_client = Aws::CloudWatch::Client.new(region: REGION)

    response = cloudwatch_client.get_metric_statistics({
      metric_name: "Started",
      namespace: METRICS_NAMESPACE,
      dimensions: [
        environment_dimension,
        form_id_dimension(form_id),
      ],
      start_time: start_of_today - 7.days,
      end_time: start_of_today,
      period: A_WEEK,
      statistics: %w[Sum],
      unit: "Count",
    })

    response.datapoints[0]&.sum.to_i || 0
  end

  def self.environment_dimension
    {
      name: "Environment",
      value: Settings.forms_env.downcase,
    }
  end

  def self.form_id_dimension(form_id)
    {
      name: "FormId",
      value: form_id.to_s,
    }
  end

  def self.start_of_today
    Time.zone.now.midnight
  end
end
