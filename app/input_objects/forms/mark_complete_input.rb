class Forms::MarkCompleteInput < BaseInput
  attr_accessor :mark_complete, :form

  validates :mark_complete, presence: true

  def marked_complete?
    mark_complete == "true"
  end
end
