class Reports::FeatureReportService
  class << self
    def report
      report = {
        total_live_forms: 0,
        live_forms_with_payment: 0,
        live_forms_with_routing: 0,
        live_forms_with_add_another_answer: 0,
        live_forms_with_csv_submission_enabled: 0,
        live_forms_with_answer_type: HashWithIndifferentAccess.new,
        live_steps_with_answer_type: HashWithIndifferentAccess.new,
      }

      Reports::FormDocumentsService.live_form_documents.each do |form|
        report[:total_live_forms] += 1
        report[:live_forms_with_payment] += 1 if form["content"]["payment_url"].present?
        report[:live_forms_with_routing] += 1 if form["content"]["steps"].any? { |step| step["routing_conditions"].present? }
        report[:live_forms_with_add_another_answer] += 1 if form["content"]["steps"].any? { |step| step["data"]["is_repeatable"] }
        report[:live_forms_with_csv_submission_enabled] += 1 if form["content"]["submission_type"] == "email_with_csv"

        answer_types_in_form = form["content"]["steps"].map { |step| step["data"]["answer_type"] }

        answer_types_in_form.uniq.each do |answer_type|
          report[:live_forms_with_answer_type][answer_type] ||= 0
          report[:live_forms_with_answer_type][answer_type] += 1
        end

        answer_types_in_form.each do |answer_type|
          report[:live_steps_with_answer_type][answer_type] ||= 0
          report[:live_steps_with_answer_type][answer_type] += 1
        end
      end

      report
    end
  end
end
