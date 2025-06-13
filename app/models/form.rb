class Form < ApplicationRecord
  has_many :pages, -> { order(position: :asc) }, dependent: :destroy
end
