class User < ApplicationRecord
  include GDS::SSO::User

  belongs_to :organisation, optional: true

  serialize :permissions, Array

  enum :role, {
    super_admin: "super_admin",
    editor: "editor",
  }

  validates :role, presence: true
  validates :organisation_id, presence: true, if: -> { organisation_id_was.present? }
end
