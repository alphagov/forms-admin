class Forms::ReceiveCsvInput < BaseInput
  attr_accessor :form, :submission_type

  validates :submission_type, presence: true

  def submit
    return false if invalid?

    form.submission_type = submission_type
    form.save!
  end

  def assign_form_values
    self.submission_type = form.try(:submission_type)
    self
  end
end
