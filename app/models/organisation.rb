class Organisation < ApplicationRecord
  has_paper_trail

  has_many :forms
  has_many :users

  has_many :mou_signatures

  scope :with_users, -> { joins(:users).distinct.order(:name) }
end
