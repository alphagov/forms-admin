class Api::V1::FormResource < ActiveResource::Base
  self.element_name = "form"
  self.site = "#{Settings.forms_api.base_url}/api/v1"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  has_many :pages, class_name: "Api::V1::PageResource"

  def self.find_live(id)
    find(:one, from: "#{prefix}forms/#{id}/live")
  end

  def self.find_archived(id)
    find(:one, from: "#{prefix}forms/#{id}/archived")
  end

  def database_attributes
    attributes
      .slice(*Form.attribute_names)
      .with_defaults(external_id: id.to_s)
  end

  def group
    group_form&.group
  end

  def qualifying_route_pages
    max_routes_per_page = 2

    conditions = pages.flat_map(&:routing_conditions).compact_blank
    condition_counts = conditions.group_by(&:check_page_id).transform_values(&:length)

    Api::V1::PageResource.qualifying_route_pages(pages).filter do |page|
      condition_counts.fetch(page.id, 0) < max_routes_per_page && page.routing_conditions.none?(&:secondary_skip?)
    end
  end

  def has_no_remaining_routes_available?
    qualifying_route_pages.none? && has_routing_conditions
  end

  def is_live?
    state.to_sym.in?(%i[live live_with_draft])
  end

  def is_archived?
    state.to_sym.in?(%i[archived archived_with_draft])
  end

  def all_ready_for_live?
    ready_for_live && email_task_status_service.ready_for_live?
  end

  def all_incomplete_tasks
    incomplete_tasks.concat(email_task_status_service.incomplete_email_tasks)
  end

  def all_task_statuses
    converted_task_statuses = task_statuses.attributes.transform_keys(&:to_sym).transform_values(&:to_sym)
    converted_task_statuses.merge(email_task_status_service.email_task_statuses)
  end

  def make_live!
    load_attributes_from_response(post("make-live"))
  end

  def archive!
    load_attributes_from_response(post("archive"))
  end

  def form_submission_email
    FormSubmissionEmail.find_by_form_id(id)
  end

  def email_confirmation_status
    # Email set before confirmation feature introduced
    return :email_set_without_confirmation if submission_email.present? && form_submission_email.blank?

    if form_submission_email.present?
      if form_submission_email.confirmed? || submission_email == form_submission_email.temporary_submission_email
        :confirmed
      else
        :sent
      end
    else
      :not_started
    end
  end

  def page_number(page)
    return pages.length + 1 if page.nil?

    index = pages.index { |existing_page| existing_page.id == page.id }
    (index.nil? ? pages.length : index) + 1
  end

  def made_live_date
    Time.zone.parse(live_at.to_s).to_date if defined?(live_at)
  end

  def file_upload_question_count
    pages.count { |p| p.answer_type.to_sym == :file }
  end

  after_destroy do
    group_form&.destroy
  end

private

  def has_routing_conditions
    pages.filter { |p| p.routing_conditions.any? }.any?
  end

  def email_task_status_service
    @email_task_status_service ||= EmailTaskStatusService.new(form: self)
  end

  def group_form
    GroupForm.find_by_form_id(id)
  end
end
