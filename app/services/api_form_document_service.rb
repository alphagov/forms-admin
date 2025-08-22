class ApiFormDocumentService
  class << self
    REQUEST_HEADERS = {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }.freeze
    FORM_DOCUMENTS_URL = "#{Settings.forms_api.base_url}/api/v2/forms".freeze

    def form_document(form_id:, tag:)
      uri = URI(FORM_DOCUMENTS_URL + "/#{form_id}/#{tag}")

      response = Net::HTTP.get_response(uri, REQUEST_HEADERS)

      return JSON.parse(response.body) if response.is_a? Net::HTTPSuccess

      raise StandardError, "Forms API responded with a non-success HTTP code when retrieving form document: status #{response.code}"
    end
  end
end
