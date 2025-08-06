class Form < ApplicationRecord
  include FormStateMachine

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
  has_one :form_submission_email, dependent: :destroy

  enum :submission_type, {
    email: "email",
    email_with_csv: "email_with_csv",
    s3: "s3",
  }

  validates :name, presence: true
  validates :payment_url, url: true, allow_blank: true
  validate :marking_complete_with_errors
  validates :submission_type, presence: true

  after_create :set_external_id

  def has_draft_version
    draft? || live_with_draft? || archived_with_draft?
  end

  def has_live_version
    live? || live_with_draft?
  end

  alias_method :is_live?, :has_live_version

  def has_been_archived
    archived? || archived_with_draft?
  end

  alias_method :is_archived?, :has_been_archived

  def has_routing_errors
    pages.filter(&:has_routing_errors).any?
  end

  alias_method :has_routing_errors?, :has_routing_errors

  def marking_complete_with_errors
    errors.add(:base, :has_validation_errors, message: "Form has routing validation errors") if question_section_completed && has_routing_errors
  end

  def move_to_group(group_id)
    group = Group.find_by!(external_id: group_id)
    group_form = GroupForm.find_by(form_id: id)

    return if group_form.group == group

    group_form.update!(group:)
  end

  def ready_for_live
    task_status_service.mandatory_tasks_completed?
  end

  def all_ready_for_live?
    ready_for_live && email_task_status_service.ready_for_live?
  end

  delegate :incomplete_tasks, to: :task_status_service

  delegate :task_statuses, to: :task_status_service

  def group
    group_form&.group
  end

  def qualifying_route_pages
    max_routes_per_page = 2

    conditions = pages.flat_map(&:routing_conditions).compact_blank
    condition_counts = conditions.group_by(&:check_page_id).transform_values(&:length)

    pages.filter do |page|
      page.answer_type == "selection" &&
        page.answer_settings.only_one_option == "true" &&
        page.position != pages.length &&
        condition_counts.fetch(page.id, 0) < max_routes_per_page &&
        page.routing_conditions.none?(&:secondary_skip?)
    end
  end

  def has_no_remaining_routes_available?
    qualifying_route_pages.none? && has_routing_conditions
  end

  def all_incomplete_tasks
    incomplete_tasks.concat(email_task_status_service.incomplete_email_tasks)
  end

  def all_task_statuses
    task_statuses.merge(email_task_status_service.email_task_statuses)
  end

  def page_number(page)
    return pages.length + 1 if page.nil?

    index = pages.index { |existing_page| existing_page.attributes == page.attributes }
    (index.nil? ? pages.length : index) + 1
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

  def file_upload_question_count
    pages.count { |p| p.answer_type.to_sym == :file }
  end

  after_destroy do
    group_form&.destroy
  end

private

  def set_external_id
    update(external_id: id)
  end

  def task_status_service
    @task_status_service ||= TaskStatusService.new(form: self)
  end

  def has_routing_conditions
    pages.filter { |p| p.routing_conditions.any? }.any?
  end

  def group_form
    GroupForm.find_by_form_id(id)
  end

  def email_task_status_service
    @email_task_status_service ||= EmailTaskStatusService.new(form: self)
  end
end
