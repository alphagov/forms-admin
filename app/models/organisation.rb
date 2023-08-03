class Organisation < ApplicationRecord
  has_paper_trail

  has_many :forms
  has_many :users
end
