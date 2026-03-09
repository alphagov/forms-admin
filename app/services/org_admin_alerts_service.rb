class OrgAdminAlertsService
  def initialize(form:, current_user:)
    @form = form
    @current_user = current_user
    @org_admins = @form.group.organisation.admin_users.where.not(id: @current_user.id)
  end

  def form_made_live
    @org_admins.each do |org_admin_user|
      form_made_live_email(to_email: org_admin_user.email).deliver_now
    end
  end

private

  def form_made_live_email(to_email:)
    previous_state = @form.state_previously_was.to_sym

    case previous_state
    when :draft
      new_draft_made_live_email(to_email:)
    when :live_with_draft
      OrgAdminAlerts::MadeLiveMailer.live_form_changes_made_live(form: @form, user: @current_user, to_email:)
    when :archived
      OrgAdminAlerts::MadeLiveMailer.archived_form_made_live(form: @form, user: @current_user, to_email:)
    when :archived_with_draft
      OrgAdminAlerts::MadeLiveMailer.archived_form_changes_made_live(form: @form, user: @current_user, to_email:)
    else
      raise StandardError, "Unexpected previous state: #{previous_state}"
    end
  end

  def new_draft_made_live_email(to_email:)
    if @form.copied_from_id.present?
      copied_from_form = Form.find(@form.copied_from_id)
      OrgAdminAlerts::MadeLiveMailer.copied_form_made_live(form: @form, copied_from_form:, user: @current_user, to_email:)
    else
      OrgAdminAlerts::MadeLiveMailer.new_draft_form_made_live(form: @form, user: @current_user, to_email:)
    end
  end
end
