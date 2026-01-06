class FormMetricsService
  def initialize(form_id)
    @form_id = form_id
  end

  def past_week_metrics_data
    {
      weekly_submissions: past_week_total_for_metric("submitted"),
      weekly_starts: past_week_total_for_metric("started"),
    }
  end

  def daily_metrics_data(start_time)
    {
      submissions: daily_totals_for_metric("submitted", start_time),
      starts: daily_totals_for_metric("started", start_time),
    }
  end

private

  def past_week_total_for_metric(metric_name)
    FormMetric.where(form_id: @form_id, metric_name: metric_name)
              .where(date: 7.days.ago.to_date..1.day.ago.to_date)
              .sum(:total)
  end

  def daily_totals_for_metric(metric_name, start_time)
    start_date = start_time.to_date
    end_date = 1.day.ago.to_date

    FormMetric
      .where(form_id: @form_id, metric_name: metric_name)
      .where(date: start_date..end_date)
      .order(date: :desc)
      .pluck(:date, :total)
      .to_h
      .transform_keys(&:iso8601)
  end
end
