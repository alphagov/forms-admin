module QuestionTextValidation
  extend ActiveSupport::Concern

  QUESTION_TEXT_MAX_LENGTH = 250

  included do
    validates :question_text, presence: true
    validates :question_text, length: { maximum: QUESTION_TEXT_MAX_LENGTH }
  end
end
