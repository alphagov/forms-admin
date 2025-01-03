require "csv"

class Reports::CsvReportsService
  REQUEST_HEADERS = { "X-API-Token" => Settings.forms_api.auth_key }.freeze
  FORM_DOCUMENTS_URL = "#{Settings.forms_api.base_url}/api/v2/form-documents".freeze

  FormDocumentsResponse = Data.define(:forms, :has_more_results?)

  def live_forms_csv
    CSV.generate do |csv|
      csv << [
        "Form ID",
        "Status",
        "Form name",
        "Slug",
        "Organisation name",
        "Organisation ID",
        "Group name",
        "Group ID",
        "Created at",
        "Updated at",
        "Number of questions",
        "Has routes",
        "Payment URL",
        "Support URL",
        "Support URL text",
        "Support email",
        "Support phone",
        "Privacy policy URL",
        "What happens next markdown",
        "Submission type",
      ]

      page = 1
      form_documents_response = get_paginated_form_documents(page)
      write_forms_to_csv(csv, form_documents_response.forms)

      while form_documents_response.has_more_results?
        page += 1
        form_documents_response = get_paginated_form_documents(page)
        write_forms_to_csv(csv, form_documents_response.forms)
      end
    end
  end

private

  def get_paginated_form_documents(page)
    response = get_form_documents(page)
    FormDocumentsResponse.new(forms: JSON.parse(response.body), has_more_results?: has_more_results?(response))
  end

  def has_more_results?(response)
    total = response["pagination-total"].to_i
    offset = response["pagination-offset"].to_i
    limit = response["pagination-limit"].to_i

    total > offset + limit
  end

  def get_form_documents(page)
    uri = URI(FORM_DOCUMENTS_URL)
    params = { tag: "live", page:, per_page: Settings.reports.forms_api_forms_per_request_page }
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get_response(uri)
  end

  def write_forms_to_csv(csv, forms)
    forms.each do |form|
      csv << form_row(form)
    end
  end

  def form_row(form)
    form_id = form["form_id"]
    group = GroupForm.find_by_form_id(form_id)&.group
    [
      form_id,
      form["tag"],
      form["content"]["name"],
      form["content"]["form_slug"],
      group&.organisation&.name,
      group&.organisation&.id,
      group&.name,
      group&.external_id,
      form["content"]["created_at"],
      form["content"]["updated_at"],
      form["content"]["steps"].length,
      form["content"]["steps"].any? { |step| step["routing_conditions"].present? },
      form["content"]["payment_url"],
      form["content"]["support_url"],
      form["content"]["support_url_text"],
      form["content"]["support_email"],
      form["content"]["support_phone"],
      form["content"]["privacy_policy_url"],
      form["content"]["what_happens_next_markdown"],
      form["content"]["submission_type"],
    ]
  end
end
