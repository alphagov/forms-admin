class Forms::MarkCompleteInput < BaseInput
  attr_accessor :mark_complete, :form

  validates :mark_complete, presence: true

  def marked_complete?
    ["true", true].include?(mark_complete)
  end
end
