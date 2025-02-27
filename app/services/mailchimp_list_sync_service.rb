class MailchimpListSyncService
  def synchronize_lists
    Rails.logger.debug "Synchronizing active users mailing list"

    MailchimpListSynchronizer.synchronize(
      list_id: Settings.mailchimp.active_users_list,
      users_to_synchronize: active_users.pluck(:email),
    )

    Rails.logger.debug "Synchronizing MOU signers mailing list"

    MailchimpListSynchronizer.synchronize(
      list_id: Settings.mailchimp.mou_signers_list,
      users_to_synchronize: mou_signers.pluck(:email),
    )
  end

  def active_users
    User.where(has_access: true)
  end

  def mou_signers
    MouSignature.all.map(&:user).filter { |user| user.has_access == true }
  end
end
