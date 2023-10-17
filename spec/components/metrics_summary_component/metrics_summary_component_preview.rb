class MetricsSummaryComponent::MetricsSummaryComponentPreview < ViewComponent::Preview
  def with_no_metrics_data
    metrics_data = nil
    render(MetricsSummaryComponent::View.new(20.days.ago.to_date, metrics_data))
  end

  def with_a_new_form
    metrics_data = { weekly_submissions: 0, form_is_new: true, weekly_starts: 0 }
    render(MetricsSummaryComponent::View.new(Time.zone.today.to_date, metrics_data))
  end

  def with_a_form_that_went_live_yesterday
    metrics_data = { weekly_submissions: 3, form_is_new: false, weekly_starts: 6 }
    render(MetricsSummaryComponent::View.new(1.day.ago.to_date, metrics_data))
  end

  def with_no_weekly_starts
    metrics_data = { weekly_submissions: 0, form_is_new: false, weekly_starts: 0 }
    render(MetricsSummaryComponent::View.new(20.days.ago.to_date, metrics_data))
  end

  def with_metrics_available
    metrics_data = { weekly_submissions: 1032, form_is_new: false, weekly_starts: 1568 }
    render(MetricsSummaryComponent::View.new(20.days.ago.to_date, metrics_data))
  end

  def with_less_than_a_week_worth_of_metrics
    metrics_data = { weekly_submissions: 1032, form_is_new: false, weekly_starts: 1568 }
    render(MetricsSummaryComponent::View.new(3.days.ago.to_date, metrics_data))
  end
end
