class FormMetricsCsvService
  MAXIMUM_LOOK_BACK = 15.months

  def self.csv(form_id:, first_made_live_at:)
    start_time = [first_made_live_at.midnight, MAXIMUM_LOOK_BACK.ago.midnight].max
    metrics_data = CloudWatchService.new(form_id).daily_metrics_data(start_time)
    end_date = Time.zone.today - 1

    CSV.generate do |csv|
      csv << headers
      end_date.downto(start_time.to_date).each do |date|
        starts = metrics_data.dig(:starts, date.iso8601) || 0
        completions = metrics_data.dig(:submissions, date.iso8601) || 0
        completion_rate = compute_completion_rate(starts, completions)
        incomplete = (starts - completions).clamp(0, starts)

        csv << [
          date.strftime("%d/%m/%Y"),
          starts.to_i,
          completions.to_i,
          completion_rate,
          incomplete.to_i,
        ]
      end
    end
  end

  def self.compute_completion_rate(starts, completions)
    return I18n.t("metrics_csv.no_starts") if starts.zero?

    sprintf("%.1f", (completions / starts * 100).round(1))
  end

  def self.headers
    [
      I18n.t("metrics_csv.headers.date"),
      I18n.t("metrics_csv.headers.started"),
      I18n.t("metrics_csv.headers.completed"),
      I18n.t("metrics_csv.headers.completion_rate"),
      I18n.t("metrics_csv.headers.started_but not completed"),
    ]
  end
end
