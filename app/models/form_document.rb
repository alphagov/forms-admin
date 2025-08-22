class FormDocument < ApplicationRecord
  belongs_to :form

  validates :tag, presence: true
end
