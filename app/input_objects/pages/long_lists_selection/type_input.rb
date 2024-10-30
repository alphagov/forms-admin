class Pages::LongListsSelection::TypeInput < BaseInput
  attr_accessor :only_one_option, :draft_question

  validates :only_one_option, inclusion: { in: %w[true false] }

  def answer_settings
    draft_question.answer_settings.merge({ only_one_option: })
  end

  def submit
    return false if invalid?

    draft_question
      .assign_attributes({ answer_settings: })

    draft_question.save!(validate: false)
  end

  def only_one_option_options
    [OpenStruct.new(id: "true"), OpenStruct.new(id: "false")]
  end
end
