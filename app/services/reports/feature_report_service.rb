class Reports::FeatureReportService
  def self.define_report(name, &block)
    @reports ||= []
    @reports << name

    define_method(name, &block)
  end

  def self.matches_report?(name)
    @reports.include? name.to_sym
  end

  class Constraint
    def self.matches?(request)
      name = request.params[:report].underscore
      Reports::FeatureReportService.matches_report? name
    end
  end

  private_class_method :define_report

  attr_reader :form_documents

  def initialize(form_documents)
    @form_documents = form_documents
  end

  def report(name = nil)
    unless name.nil?
      raise "'#{name}' is not a defined report" unless self.class.matches_report?(name)

      return send(name)
    end

    report = {
      total_forms: 0,
      forms_with_payment: 0,
      forms_with_routing: 0,
      forms_with_branch_routing: 0,
      forms_with_add_another_answer: 0,
      forms_with_csv_submission_enabled: 0,
      forms_with_answer_type: HashWithIndifferentAccess.new,
      steps_with_answer_type: HashWithIndifferentAccess.new,
    }

    form_documents.each do |form|
      report[:total_forms] += 1
      report[:forms_with_payment] += 1 if Reports::FormDocumentsService.has_payments?(form)
      report[:forms_with_routing] += 1 if Reports::FormDocumentsService.has_routes?(form)
      report[:forms_with_branch_routing] += 1 if Reports::FormDocumentsService.has_secondary_skip_routes?(form)
      report[:forms_with_add_another_answer] += 1 if form["content"]["steps"].any? { |step| step["data"]["is_repeatable"] }
      report[:forms_with_csv_submission_enabled] += 1 if Reports::FormDocumentsService.has_csv_submission_enabled?(form)

      answer_types_in_form = form["content"]["steps"].map { |step| step["data"]["answer_type"] }

      answer_types_in_form.uniq.each do |answer_type|
        report[:forms_with_answer_type][answer_type] ||= 0
        report[:forms_with_answer_type][answer_type] += 1
      end

      answer_types_in_form.each do |answer_type|
        report[:steps_with_answer_type][answer_type] ||= 0
        report[:steps_with_answer_type][answer_type] += 1
      end
    end

    report
  end

  def questions
    form_documents.flat_map do |form|
      form["content"]["steps"]
        .map { |step| questions_details(form, step) }
    end
  end

  def questions_with_answer_type(answer_type)
    form_documents.flat_map do |form|
      form["content"]["steps"]
        .select { |step| step["data"]["answer_type"] == answer_type }
        .map { |step| questions_details(form, step) }
    end
  end

  define_report :questions_with_add_another_answer do
    form_documents.flat_map do |form|
      form["content"]["steps"]
        .select { |step| step["data"]["is_repeatable"] }
        .map { |step| questions_details(form, step) }
    end
  end

  define_report :forms_with_routes do
    form_documents
      .select { |form| Reports::FormDocumentsService.has_routes?(form) }
      .map { |form| form_with_routes_details(form) }
  end

  define_report :forms_with_branch_routes do
    form_documents
      .select { |form| Reports::FormDocumentsService.has_secondary_skip_routes?(form) }
      .map { |form| form_with_routes_details(form) }
  end

  define_report :forms_with_payments do
    form_documents
      .select { |form| Reports::FormDocumentsService.has_payments?(form) }
      .map { |form| form_details(form) }
  end

  define_report :forms_with_csv_submission_enabled do
    form_documents
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
      "number_of_branch_routes" => Reports::FormDocumentsService.count_secondary_skip_routes(form),
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
