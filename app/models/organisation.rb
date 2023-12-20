class Organisation < ApplicationRecord
  has_paper_trail

  has_many :domains

  has_many :forms
  has_many :users

  has_many :mou_signatures
end
