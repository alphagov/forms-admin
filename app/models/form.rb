class Form < ApplicationRecord
  include FormStateMachine

  has_many :pages, -> { order(position: :asc) }, dependent: :destroy

  enum :submission_type, {
    email: "email",
    email_with_csv: "email_with_csv",
    s3: "s3",
  }

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
