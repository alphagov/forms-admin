class Form < ApplicationRecord
  include FormStateMachine
  extend Mobility

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
  has_one :form_submission_email, dependent: :destroy
  has_one :group_form, dependent: :destroy
  has_many :form_documents, dependent: :destroy
  has_one :live_form_document, -> { where tag: "live" }, class_name: "FormDocument"
  has_one :archived_form_document, -> { where tag: "archived" }, class_name: "FormDocument"
  has_one :draft_form_document, -> { where tag: "draft" }, class_name: "FormDocument"
  has_many :conditions, through: :pages, source: :routing_conditions

  translates :name,
             :privacy_policy_url,
             :support_email,
             :support_phone,
             :support_url,
             :support_url_text,
             :declaration_text,
             :what_happens_next_markdown,
             :payment_url

  enum :submission_type, {
    email: "email",
    email_with_csv: "email_with_csv",
    email_with_json: "email_with_json",
    email_with_csv_and_json: "email_with_csv_and_json",
    s3: "s3",
    s3_with_json: "s3_with_json",
  }

  enum :language, {
    en: "en",
    cy: "cy",
  }

  validates :name, presence: true
  validates :payment_url, url: true, allow_blank: true
  validate :marking_complete_with_errors
  validates :submission_type, presence: true
  validates :available_languages, presence: true, inclusion: { in: Form.languages }
  validates :submission_email, email_address: { message: :invalid_email }, allow_blank: true
  validates :support_email, email_address: { message: :invalid_email }, allow_blank: true

  after_create :set_external_id
  after_update :update_draft_form_document
  ATTRIBUTES_NOT_IN_FORM_DOCUMENT = %i[state external_id pages question_section_completed declaration_section_completed share_preview_completed welsh_completed].freeze

  def save_question_changes!
    self.question_section_completed = false
    save_draft!
  end

  def save_draft!
    save!
    create_draft_from_live_form! if live?
    create_draft_from_archived_form! if archived?
    true
  end

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

  # We need to include the splat operator as second argument,
  # since Mobility expects this when using locale setters like `name_cy=`
  def name=(val, ...)
    super

    # Always set form_slug using the English name
    self[:form_slug] = name_en.parameterize
  end

  # form_slug is always set based on name
  def form_slug=(slug); end

  def has_routing_errors
    pages.filter(&:has_routing_errors).any?
  end

  alias_method :has_routing_errors?, :has_routing_errors

  def marking_complete_with_errors
    errors.add(:base, :has_validation_errors, message: "Form has routing validation errors") if question_section_completed && has_routing_errors
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
    return pages.length + 1 if page.id.nil?

    index = pages.index { |existing_page| existing_page.id == page.id }
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

  def as_form_document(live_at: nil)
    content = as_json(
      except: ATTRIBUTES_NOT_IN_FORM_DOCUMENT,
      methods: %i[start_page steps],
    )
    content["form_id"] = content.delete("id").to_s
    content["live_at"] = live_at if live_at.present?
    content
  end

private

  def set_external_id
    update(external_id: id)
  end

  def update_draft_form_document
    FormDocumentSyncService.update_draft_form_document(self)
  end

  def task_status_service
    # TODO: refactor this in favour of dependency injection
    # it can also lead to use of `allow_any_instance_of` in testing
    @task_status_service ||= TaskStatusService.new(form: self)
  end

  def has_routing_conditions
    pages.filter { |p| p.routing_conditions.any? }.any?
  end

  def group_form
    GroupForm.find_by_form_id(id)
  end

  def email_task_status_service
    # TODO: refactor this in favour of dependency injection
    # it can also lead to use of `allow_any_instance_of` in testing
    @email_task_status_service ||= EmailTaskStatusService.new(form: self)
  end

  def steps
    ordered_pages = pages.includes(:routing_conditions).to_a
    ordered_pages.map.with_index do |page, index|
      next_page = ordered_pages.fetch(index + 1, nil)
      page.as_form_document_step(next_page)
    end
  end

  def start_page
    pages&.first&.id
  end
end
