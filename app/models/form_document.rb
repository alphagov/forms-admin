class FormDocument < ApplicationRecord
  belongs_to :form

  validates :tag, presence: true
  validates :language, presence: true, inclusion: { in: %w[en cy] }
end
