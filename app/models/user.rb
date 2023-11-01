class User < ApplicationRecord
  include GDS::SSO::User
  has_paper_trail only: %i[role organisation_id has_access]

  class UserAuthenticationException < StandardError; end

  belongs_to :organisation, optional: true
  has_many :mou_signatures
  has_many :draft_questions

  serialize :permissions, Array

  enum :role, {
    super_admin: "super_admin",
    editor: "editor",
    trial: "trial",
  }

  validates :name, presence: true, if: :requires_name?
  validates :role, presence: true
  validates :organisation_id, presence: true, if: :requires_organisation?
  validates :has_access, inclusion: [true, false]

  def self.find_for_gds_oauth(auth_hash)
    find_for_auth(
      provider: auth_hash["provider"],
      uid: auth_hash["uid"],
      email: auth_hash["info"]["email"],
      name: auth_hash["info"]["name"],
      permissions: auth_hash["extra"]["user"]["permissions"].to_a,
      organisation_slug: auth_hash["extra"]["user"]["organisation_slug"],
      organisation_content_id: auth_hash["extra"]["user"]["organisation_content_id"],
      disabled: auth_hash["extra"]["user"]["disabled"],
    )
  end

  def self.find_for_auth(attributes)
    user = where(provider: attributes[:provider], uid: attributes[:uid]).first ||
      where(email: attributes[:email]).first

    if user
      user.assign_attributes(attributes)

      if user.has_changes_to_save?
        EventLogger.log({
          event: "auth",
          user_id: user.id,
          user_changes: user.changes_to_save,
        })
      end

      user.save!
      user
    else # Create a new user.
      create!(attributes)
    end
  end

  def organisation_valid?
    trial? || organisation.present?
  end

  def trial_user_upgraded?
    role_previously_changed?(from: :trial, to: :editor) || role_previously_changed?(from: :trial, to: :super_admin)
  end

  def given_organisation?
    organisation_id.present? && organisation_id_previously_changed?(from: nil)
  end

  def has_signed_current_organisation_mou?
    mou_signatures.where(organisation: organisation || nil).exists?
  end

  def current_organisation_mou_signature
    mou_signatures.find_by(organisation:)
  end

private

  def requires_name?
    name_was.present? || role_changed?(from: :trial)
  end

  def requires_organisation?
    organisation_id_was.present? || role_changed?(to: :editor)
  end
end
