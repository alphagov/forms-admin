class Form < ActiveResource::Base
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

  def group
    group_form&.group
  end

  def qualifying_route_pages
    Api::V1::PageResource.qualifying_route_pages(pages)
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
    post "make-live"
  end

  def archive!
    post "archive"
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

    index = pages.index { |existing_page| existing_page.attributes == page.attributes }
    (index.nil? ? pages.length : index) + 1
  end

  def made_live_date
    Time.zone.parse(live_at.to_s).to_date if defined?(live_at)
  end

  def metrics_data
    return nil if made_live_date.nil?

    # If the form went live today, there won't be any metrics to show
    today = Time.zone.today

    form_is_new = made_live_date == today

    weekly_submissions = form_is_new ? 0 : CloudWatchService.week_submissions(form_id: id)
    weekly_starts = form_is_new ? 0 : CloudWatchService.week_starts(form_id: id)

    {
      weekly_submissions:,
      weekly_starts:,
    }
  rescue Aws::CloudWatch::Errors::ServiceError,
         Aws::Errors::MissingCredentialsError => e

    Sentry.capture_exception(e)
    nil
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
