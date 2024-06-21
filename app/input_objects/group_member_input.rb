class GroupMemberInput < BaseInput
  include ActiveModel::Validations::Callbacks
  include Rails.application.routes.url_helpers

  attr_accessor :member_email_address, :group, :creator, :host, :role

  EMAIL_REGEX = /.*@.*/

  validates :member_email_address, presence: true
  validates :role, presence: true
  validates :member_email_address, format: { with: EMAIL_REGEX, message: :invalid_email }
  validate :invited_user_has_account, if: -> { member_email_address.present? }

  before_validation :strip_whitespace

  def submit
    if invalid? || new_membership.invalid?
      copy_membership_errors
      return false
    end

    new_membership.save!
    send_notification_email

    true
  end

  def role_options
    Membership.roles.keys.map { |role| [I18n.t("membership.roles.#{role}"), role] }
  end

  def invited_user
    @invited_user ||= User.find_by(email: member_email_address)
  end

private

  def new_membership
    @new_membership ||= group.memberships.new(user: invited_user, role:, added_by: creator)
  end

  def invited_user_has_account
    return if invited_user.present?

    errors.add(:member_email_address, :not_forms_user)
  end

  def copy_membership_errors
    new_membership.errors.each do |err|
      errors.add(:member_email_address, err.type)
    end
  end

  def strip_whitespace
    member_email_address&.strip!
  end

  def send_notification_email
    GroupMemberMailer.added_to_group(new_membership, group_url: group_url(group, host:)).deliver_now
  end
end
