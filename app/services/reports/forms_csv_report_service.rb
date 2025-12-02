require "csv"

class Reports::FormsCsvReportService
  FORM_CSV_HEADERS = [
    "Form ID",
    "Status",
    "Form name",
    "Slug",
    "Organisation name",
    "Organisation ID",
    "Group name",
    "Group ID",
    "Created",
    "First made live",
    "Last made live",
    "Number of questions",
    "Has routes",
    "Has branch routes",
    "Has exit pages",
    "Has add another answer",
    "Payment URL",
    "Support URL",
    "Support URL text",
    "Support email",
    "Support phone",
    "Privacy policy URL",
    "What happens next markdown",
    "Submission type",
    "Submission formats",
    "Language",
  ].freeze

  attr_reader :form_documents

  def initialize(form_documents)
    @form_documents = form_documents
  end

  def csv
    CSV.generate do |csv|
      csv << FORM_CSV_HEADERS

      form_documents.each do |form_document|
        csv << form_row(form_document)
      end
    end
  end

private

  def form_row(form)
    form_id = form["form_id"]
    [
      form_id,
      form["tag"],
      form["content"]["name"],
      form["content"]["form_slug"],
      form["organisation_name"],
      form["organisation_id"],
      form["group_name"],
      form["group_external_id"],
      form["content"]["created_at"],
      form["content"]["first_made_live_at"],
      form["content"]["live_at"],
      form["content"]["steps"].length,
      form["content"]["steps"].any? { |step| step["routing_conditions"].present? },
      Reports::FormDocumentsService.has_secondary_skip_routes?(form),
      Reports::FormDocumentsService.has_exit_pages?(form),
      Reports::FormDocumentsService.has_add_another_answer?(form),
      form["content"]["payment_url"],
      form["content"]["support_url"],
      form["content"]["support_url_text"],
      form["content"]["support_email"],
      form["content"]["support_phone"],
      form["content"]["privacy_policy_url"],
      form["content"]["what_happens_next_markdown"],
      form["content"]["submission_type"],
      form["content"]["submission_format"]&.sort&.join(" "),
      form["content"]["language"],
    ]
  end
end
