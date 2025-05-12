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
        report[:live_forms_with_payment] += 1 if Reports::FormDocumentsService.has_payments?(form)
        report[:live_forms_with_routing] += 1 if Reports::FormDocumentsService.has_routes?(form)
        report[:live_forms_with_add_another_answer] += 1 if form["content"]["steps"].any? { |step| step["data"]["is_repeatable"] }
        report[:live_forms_with_csv_submission_enabled] += 1 if Reports::FormDocumentsService.has_csv_submission_enabled?(form)

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

    def questions_with_answer_type(answer_type)
      Reports::FormDocumentsService.live_form_documents.flat_map do |form|
        form["content"]["steps"]
          .select { |step| step["data"]["answer_type"] == answer_type }
          .map { |step| questions_details(form, step) }
      end
    end

    def live_questions_with_add_another_answer
      Reports::FormDocumentsService.live_form_documents.flat_map do |form|
        form["content"]["steps"]
          .select { |step| step["data"]["is_repeatable"] }
          .map { |step| questions_details(form, step) }
      end
    end

    def live_forms_with_routes
      Reports::FormDocumentsService.live_form_documents
                                   .select { |form| Reports::FormDocumentsService.has_routes?(form) }
                                   .map { |form| form_with_routes_details(form) }
    end

    def live_forms_with_payments
      Reports::FormDocumentsService.live_form_documents
                                   .select { |form| Reports::FormDocumentsService.has_payments?(form) }
                                   .map { |form| form_details(form) }
    end

    def live_forms_with_csv_submission_enabled
      Reports::FormDocumentsService.live_form_documents
                                   .select { |form| Reports::FormDocumentsService.has_csv_submission_enabled?(form) }
                                   .map { |form| form_details(form) }
    end

  private

    def questions_details(form, step)
      form = form_details(form)
      step.dup.merge("form" => form)
    end

    def form_with_routes_details(form)
      form = form_details(form)
      form["metadata"] = {
        "number_of_routes" => form["content"]["steps"].count { |step| step["routing_conditions"].present? },
      }
      form
    end

    def form_details(form)
      form = form.dup
      form["group"] = {
        "organisation" => {
          "name" => organisation_name(form["form_id"]),
        },
      }
      form
    end

    def organisation_name(form_id)
      GroupForm.find_by_form_id(form_id)&.group&.organisation&.name
    end
  end
end
