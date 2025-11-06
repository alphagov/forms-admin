class Forms::SubmissionTypeInput < BaseInput
  attr_accessor :form, :submission_type

  validates :submission_type, presence: true

  def submit
    return false if invalid?

    form.submission_type = submission_type
    form.submission_format = submission_format
    form.save_draft!
  end

  def assign_form_values
    self.submission_type = form.try(:submission_type)
    self
  end

  def submission_format
    return nil if submission_type.blank?
    return [] if submission_type == "email"

    formats = []
    formats << "csv" if submission_type.include? "csv"
    formats
  end

  def submission_format=(formats)
    self.submission_type = if formats.nil?
                             nil
                           else
                             formats.include?("csv") ? "email_with_csv" : "email"
                           end
  end
end
