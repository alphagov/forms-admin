class Pages::NameSettingsForm < BaseForm
  attr_accessor :input_type, :title_needed, :draft_question

  INPUT_TYPES = %w[full_name first_and_last_name first_middle_and_last_name].freeze
  TITLE_NEEDED = %w[true false].freeze

  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }
  validates :title_needed, presence: true, inclusion: { in: TITLE_NEEDED }

  def submit
    return false if invalid?

    draft_question.answer_settings[:input_type] = input_type
    draft_question.answer_settings[:title_needed] = title_needed
    draft_question.save!(validate: false)
  end
end
