class Pages::NameSettingsForm < BaseForm
  attr_accessor :input_type, :title_needed, :draft_question

  INPUT_TYPES = %w[full_name first_and_last_name first_middle_and_last_name].freeze
  TITLE_NEEDED = %w[true false].freeze

  validates :draft_question, presence: true
  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }
  validates :title_needed, presence: true, inclusion: { in: TITLE_NEEDED }

  def submit(session)
    return false if invalid?

    # Set the answer_settings hash
    answer_settings = {
      input_type:,
      title_needed:,
    }

    # Set answer_settings for the draft_question
    draft_question.answer_settings = answer_settings.with_indifferent_access
    draft_question.save!(validate: false)

    # TODO: remove this once we have draft_questions being saved across the whole journey
    session[:page] = {} if session[:page].blank?
    session[:page][:answer_settings] = { input_type:, title_needed: }
  end
end
