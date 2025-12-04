module Forms
  class MetricsController < WebController
    after_action :verify_authorized

    FORM_NAME_IN_FILENAME_MAX_LENGTH = 85 # limit the filename length to 100 characters

    def metrics_csv
      authorize current_form, :can_view_form?

      csv_data = FormMetricsCsvService.csv(
        form_id: current_form.id,
        first_made_live_at: form_document.first_made_live_at,
      )

      send_data csv_data,
                type: "text/csv; charset=iso-8859-1",
                disposition: "attachment; filename=#{csv_filename(form_document)}"
    end

  private

    def csv_filename(form_document)
      name_part = form_document.name
      .parameterize(separator: "_")
      .truncate(FORM_NAME_IN_FILENAME_MAX_LENGTH, separator: "_", omission: "")

      "#{name_part}_#{Time.zone.today}.csv"
    end

    def form_document
      @form_document ||= find_form_document
    end

    def find_form_document
      live_or_archived_form_document = current_form.form_documents.where(tag: %w[live archived]).first

      raise NotFoundError if live_or_archived_form_document.nil?

      FormDocument::Content.from_form_document(live_or_archived_form_document)
    end
  end
end
