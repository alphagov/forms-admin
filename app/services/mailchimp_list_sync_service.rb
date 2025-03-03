class MailchimpListSyncService
  def synchronize_lists
    Rails.logger.debug "Synchronizing active users mailing list"
    active_users_list = Settings.mailchimp.active_users_list
    active_user_email_addresses = User.where(has_access: true).pluck(:email)

    MailchimpListSynchronizer.synchronize(list_id: active_users_list, users_to_synchronize: active_user_email_addresses)

    Rails.logger.debug "Synchronizing MOU signers mailing list"
    mou_signers_list = Settings.mailchimp.mou_signers_list
    mou_signer_email_addresses = MouSignature.all.map(&:user).filter { |user| user.has_access == true }.pluck(:email)

    MailchimpListSynchronizer.synchronize(list_id: mou_signers_list, users_to_synchronize: mou_signer_email_addresses)
  end
end
