class User < ApplicationRecord
  include GDS::SSO::User
  has_paper_trail only: %i[role organisation_id has_access]

  class UserAuthenticationException < StandardError; end

  EMAIL_DOMAIN_DENYLIST = [
    "dwp.gov.uk",
    "engineering.dwp.gov.uk",
    "engineering.digital.dwp.gov.uk",
    "hse.gov.uk",
  ].freeze

  belongs_to :organisation, optional: true

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  has_many :mou_signatures
  has_many :draft_questions

  serialize :permissions, coder: YAML, type: Array

  enum :role, {
    super_admin: "super_admin",
    organisation_admin: "organisation_admin",
    standard: "standard",
  }

  validates :name, presence: true, if: :requires_name?
  validates :role, presence: true
  validates :organisation_id, presence: true, if: :requires_organisation?
  validates :has_access, inclusion: [true, false]
  validates :role, exclusion: %w[organisation_admin], unless: :current_org_has_mou?
  validates :email, uniqueness: { case_sensitive: false }

  before_create do
    self.has_access = false if organisation_restricted_access?
  end

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
        Rails.logger.info("User attributes updated upon authorisation", {
          user_changes: user.changes_to_save,
        })
      end

      user.save!
      user
    else # Create a new user.
      create!(attributes)
    end
  end

  def given_organisation?
    organisation_id.present? && organisation_id_previously_changed?(from: nil)
  end

  def has_signed_current_organisation_mou?
    mou_signatures.where(organisation: organisation || nil).exists?
  end

  def organisation_restricted_access?
    email_domain = email.present? ? email.split("@").last : nil

    EMAIL_DOMAIN_DENYLIST.include?(email_domain)
  end

  def current_organisation_mou_signature
    mou_signatures.find_by(organisation:)
  end

  def is_organisations_admin?(org)
    organisation_admin? && organisation == org
  end

  def is_group_admin?(group)
    memberships.find_by(group:)&.group_admin?
  end

  def current_org_has_mou?
    organisation&.mou_signatures.present?
  end

  def collect_analytics?
    Settings.analytics_enabled && !super_admin?
  end

private

  def requires_name?
    name_was.present?
  end

  def requires_organisation?
    organisation_id_was.present? || role_changed?(to: :organisation_admin)
  end
end
