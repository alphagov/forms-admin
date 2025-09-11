class Reports::FormDocumentsService
  class << self
    def form_documents(tag:)
      form_documents = FormDocument.joins(form: { group_form: { group: :organisation } })
                  .where(tag:)
                  .where.not(organisation: { "internal": true })
                  .select("form_documents.*", "organisation.name AS organisation_name", "organisation.id AS organisation_id", "groups.external_id AS group_external_id", "groups.name AS group_name")

      if tag == "draft"
        form_documents = form_documents.where(form: { "state": %w[draft live_with_draft archived_with_draft] })
      end

      form_documents.find_each(batch_size: 100).lazy.map(&:as_json)
    end

    def has_routes?(form_document)
      form_document["content"]["steps"].any? { |step| step["routing_conditions"].present? }
    end

    def has_secondary_skip_routes?(form_document)
      secondary_skip_conditions(form_document).any?
    end

    def count_secondary_skip_routes(form_document)
      secondary_skip_conditions(form_document).count
    end

    def step_has_secondary_skip_route?(form_document, step)
      secondary_skip_conditions(form_document).any? do |condition|
        condition["check_page_id"] == step["id"]
      end
    end

    def has_payments?(form_document)
      form_document["content"]["payment_url"].present?
    end

    def has_csv_submission_enabled?(form_document)
      form_document["content"]["submission_type"] == "email_with_csv"
    end

    def has_exit_pages?(form_document)
      form_document["content"]["steps"].any? do |step|
        step["routing_conditions"].any? do |condition|
          condition["exit_page_markdown"].present?
        end
      end
    end

  private

    def secondary_skip_conditions(form_document)
      form_document["content"]["steps"].lazy.flat_map do |step|
        (step["routing_conditions"]&.lazy || []).reject do |condition|
          condition["check_page_id"] == condition["routing_page_id"]
        end
      end
    end
  end
end
