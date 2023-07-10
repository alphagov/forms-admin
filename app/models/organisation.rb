class Organisation < ApplicationRecord
  has_many :forms
  has_many :users
end
