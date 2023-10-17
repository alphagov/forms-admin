# frozen_string_literal: true

module MetricsSummaryComponent
  class View < ViewComponent::Base
    attr_accessor :start_date, :end_date, :weekly_submissions, :weekly_starts, :weekly_started_but_not_completed, :weekly_completion_rate, :form_has_metrics, :error_message, :heading

    def initialize(form_live_date, metrics_data)
      super
      @start_date = [form_live_date, 7.days.ago.to_date].max
      @end_date = 1.day.ago.to_date
      @heading = heading_text.html_safe

      if metrics_data.nil?
        @error_message = I18n.t("metrics_summary.errors.error_loading_data_html")
      elsif metrics_data[:form_is_new]
        @error_message = I18n.t("metrics_summary.errors.new_form_html")
      elsif metrics_data[:weekly_starts].zero?
        @error_message = I18n.t("metrics_summary.errors.no_submissions_html")
      else
        @weekly_submissions = metrics_data[:weekly_submissions]
        @weekly_starts = metrics_data[:weekly_starts]
        @weekly_started_but_not_completed = @weekly_starts - @weekly_submissions
        @weekly_completion_rate = I18n.t("metrics_summary.percentage", number: calculate_percentage(@weekly_submissions, @weekly_starts))
      end
    end

    def render?
      FeatureService.enabled?(:metrics_for_form_creators_enabled)
    end

    def formatted_date_range
      start_date_format_string = start_date.year == end_date.year ? "%e %B" : "%e %B %Y"
      formatted_start_date = format_date(start_date.strftime(start_date_format_string))
      formatted_end_date = format_date(end_date.strftime("%e %B %Y"))
      I18n.t("metrics_summary.date_range", start_date: formatted_start_date, end_date: formatted_end_date)
    end

    def number_of_days
      # We add 1 because we're calculating the number of days from the start date
      # to end date inclusive, not the difference between them
      (end_date - start_date).to_i + 1
    end

    def complete_week?
      number_of_days == 7
    end

    def calculate_percentage(number, total)
      return nil if total.zero?

      (number.to_f * 100 / total).round
    end

    def description
      complete_week? ? I18n.t("metrics_summary.description.complete_week") : I18n.t("metrics_summary.description.incomplete_week")
    end

    def heading_text
      if start_date == Time.zone.today
        I18n.t("metrics_summary.heading_without_dates")
      elsif start_date == Time.zone.yesterday
        I18n.t("metrics_summary.heading_with_single_date", date: format_date(start_date.strftime("%e %B %Y")))
      else
        I18n.t("metrics_summary.heading_with_dates", number_of_days:, formatted_date_range:)
      end
    end

  private

    def format_date(date)
      "<span class=\"app-metrics__date\">#{date.strip}</span>"
    end
  end
end
