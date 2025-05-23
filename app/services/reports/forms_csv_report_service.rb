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
