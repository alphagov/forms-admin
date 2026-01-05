class Api::FormMetricsController < ApplicationController
  skip_forgery_protection

  def record_form_started
    FormMetric.increment_started_total!(form_id)
    head :ok
  end

  def record_form_submitted
    FormMetric.increment_submitted_total!(form_id)
    head :ok
  end

private

  def form_id
    params.require(:form_id)
  end
end
