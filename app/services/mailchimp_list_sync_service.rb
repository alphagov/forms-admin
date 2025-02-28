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
    MouSignature
      .all
      .map(&:user)
      .filter { |user| user.has_access == true }
      .pluck(:email)
      .map { |email| MailchimpMember.new(email: email, status: "subscribed") }
  end
end
