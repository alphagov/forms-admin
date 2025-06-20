class Reports::FormDocumentsService
  class << self
    REQUEST_HEADERS = {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }.freeze
    FORM_DOCUMENTS_URL = "#{Settings.forms_api.base_url}/api/v2/form-documents".freeze

    FormDocumentsResponse = Data.define(:forms, :has_more_results?)

    def draft_form_documents
      form_documents(tag: "draft")
    end

    def live_form_documents
      form_documents(tag: "live")
    end

    def form_documents(tag:)
      Enumerator.new do |yielder|
        page = 1
        loop do
          form_documents_response = form_documents_page(tag:, page:)
          form_documents_response.forms.each { |f| yielder << f unless is_in_internal_organisation?(f) }

          break unless form_documents_response.has_more_results?

          page += 1
        end
      end
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

    def form_documents_page(tag:, page:)
      uri = URI(FORM_DOCUMENTS_URL)
      params = { tag:, page:, per_page: Settings.reports.forms_api_forms_per_request_page }
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri, REQUEST_HEADERS)

      return parse_response(response) if response.is_a? Net::HTTPSuccess

      raise StandardError, "Forms API responded with a non-success HTTP code when retrieving form documents: status #{response.code}"
    end

    def parse_response(response)
      FormDocumentsResponse.new(forms: JSON.parse(response.body), has_more_results?: has_more_results?(response))
    end

    def has_more_results?(response)
      total = response["pagination-total"].to_i
      offset = response["pagination-offset"].to_i
      limit = response["pagination-limit"].to_i

      total > offset + limit
    end

    def is_in_internal_organisation?(form)
      group_form = GroupForm.find_by_form_id(form["form_id"])

      return false if group_form.blank?

      group_form.group.organisation.internal?
    end

    def secondary_skip_conditions(form_document)
      form_document["content"]["steps"].lazy.flat_map do |step|
        (step["routing_conditions"]&.lazy || []).reject do |condition|
          condition["check_page_id"] == condition["routing_page_id"]
        end
      end
    end
  end
end
