class CloudWatchService
  REGION = "eu-west-2".freeze
  A_WEEK = 604_800
  METRICS_NAMESPACE = "Forms".freeze

  attr_reader :form_id, :made_live_date

  def initialize(form_id, made_live_date)
    @form_id = form_id
    @made_live_date = made_live_date
  end

  def metrics_data
    return nil if made_live_date.nil?

    # If the form went live today, there won't be any metrics to show
    today = Time.zone.today

    form_is_new = made_live_date == today

    weekly_submissions = form_is_new ? 0 : week_submissions(form_id:)
    weekly_starts = form_is_new ? 0 : week_starts(form_id:)

    {
      weekly_submissions:,
      weekly_starts:,
    }
  rescue Aws::CloudWatch::Errors::ServiceError,
         Aws::Errors::MissingCredentialsError => e

    Sentry.capture_exception(e)
    nil
  end

private

  def week_submissions(form_id:)
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

  def week_starts(form_id:)
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

  def environment_dimension
    {
      name: "Environment",
      value: Settings.forms_env.downcase,
    }
  end

  def form_id_dimension(form_id)
    {
      name: "FormId",
      value: form_id.to_s,
    }
  end

  def start_of_today
    Time.zone.now.midnight
  end
end
