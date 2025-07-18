class Form < ApplicationRecord
  include FormStateMachine

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy

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

  def has_been_archived
    archived? || archived_with_draft?
  end

  def has_routing_errors
    pages.filter(&:has_routing_errors).any?
  end

  def marking_complete_with_errors
    errors.add(:base, :has_validation_errors, message: "Form has routing validation errors") if question_section_completed && has_routing_errors
  end

  def ready_for_live
    task_status_service.mandatory_tasks_completed?
  end

private

  def set_external_id
    update(external_id: id)
  end

  def task_status_service
    @task_status_service ||= TaskStatusService.new(form: self)
  end
end
