class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :added_by, class_name: "User"
end
