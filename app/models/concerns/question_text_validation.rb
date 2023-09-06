module QuestionTextValidation
  extend ActiveSupport::Concern

  included do
    validates :question_text, presence: true
    validates :question_text, length: { maximum: 250 }
  end
end
