class Pages::TextSettingsForm < BaseForm
  attr_accessor :input_type, :draft_question

  INPUT_TYPES = %w[single_line long_text].freeze

  validates :draft_question, presence: true
  validates :input_type, presence: true, inclusion: { in: INPUT_TYPES }

  def submit(session)
    return false if invalid?

    # Set the answer_settings hash
    answer_settings = {
      input_type:,
    }

    # Set answer_settings for the draft_question
    draft_question.answer_settings = answer_settings.with_indifferent_access
    draft_question.save!(validate: false)

    # TODO: remove this once we have draft_questions being saved across the whole journey
    session[:page] = {} if session[:page].blank?
    session[:page][:answer_settings] = { input_type: }
  end
end
