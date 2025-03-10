class MailchimpListSyncService
  def synchronize_lists
    Rails.logger.debug "Synchronizing active users mailing list"
    MailchimpListSynchronizer.new(list_id: Settings.mailchimp.active_users_list).synchronize(desired_members: active_users)

    Rails.logger.debug "Synchronizing MOU signers mailing list"
    MailchimpListSynchronizer.new(list_id: Settings.mailchimp.mou_signers_list).synchronize(desired_members: mou_signers)
  end

  def active_users
    User
      .where(has_access: true)
      .pluck(:email)
      .map { |email| MailchimpMember.new(email: email, status: "subscribed") }
  end

  def mou_signers
    User
      .left_outer_joins(:mou_signatures)
      .where(has_access: true)
      .where("mou_signatures.id IS NOT NULL OR users.role = ?", "organisation_admin")
      .distinct
      .map { |user| MailchimpMember.new(email: user.email, status: "subscribed", role: mou_role(user)) }
  end

private

  def mou_role(user)
    if user.mou_signatures.present? && user.organisation_admin?
      "Organisation admin agreed MOU"
    elsif user.mou_signatures.present?
      "Agreed MOU"
    elsif user.organisation_admin?
      "Organisation admin"
    end
  end
end
