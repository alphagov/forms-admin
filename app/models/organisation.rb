class Organisation < ApplicationRecord
  has_paper_trail

  has_many :forms
  has_many :users

  has_many :mou_signatures

  scope :with_users, -> { where(User.where("organisation_id = organisations.id").arel.exists).order(:name) }
end
