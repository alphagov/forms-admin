class Reports::FormDocumentsService
  class << self
    REQUEST_HEADERS = {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }.freeze
    FORM_DOCUMENTS_URL = "#{Settings.forms_api.base_url}/api/v2/form-documents".freeze

    FormDocumentsResponse = Data.define(:forms, :has_more_results?)

    def live_form_documents
      Enumerator.new do |yielder|
        page = 1
        loop do
          form_documents_response = live_form_documents_page(page)
          form_documents_response.forms.each { |f| yielder << f }

          break unless form_documents_response.has_more_results?

          page += 1
        end
      end
    end

  private

    def live_form_documents_page(page)
      uri = URI(FORM_DOCUMENTS_URL)
      params = { tag: "live", page:, per_page: Settings.reports.forms_api_forms_per_request_page }
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
  end
end
