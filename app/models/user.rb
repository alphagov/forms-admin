class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, Array

  enum :role, {
    super_admin: "super_admin",
    editor: "editor",
  }
end
