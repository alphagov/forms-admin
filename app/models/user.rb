class User < ApplicationRecord
  include GDS::SSO::User
  attr_accessor :super_admin_user
  serialize :permissions, Array
end
