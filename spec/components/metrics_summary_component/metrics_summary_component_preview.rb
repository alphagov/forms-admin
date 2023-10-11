class MetricsSummaryComponent::MetricsSummaryComponentPreview < ViewComponent::Preview
  def with_no_metrics_data
    metrics_data = nil
    render(MetricsSummaryComponent::View.new(metrics_data))
  end

  def with_a_new_form
    metrics_data = { weekly_submissions: 0, form_is_new: true, weekly_starts: 0 }
    render(MetricsSummaryComponent::View.new(metrics_data))
  end

  def with_metrics_available
    metrics_data = { weekly_submissions: 1032, form_is_new: false, weekly_starts: 1568 }
    render(MetricsSummaryComponent::View.new(metrics_data))
  end
end
