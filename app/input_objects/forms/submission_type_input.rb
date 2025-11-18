class Forms::SubmissionTypeInput < BaseInput
  attr_accessor :form, :submission_type

  validates :submission_type, presence: true

  def submit
    return false if invalid?

    form.submission_format = submission_format
    form.save_draft!
  end

  def assign_form_values
    if form.submission_format.nil?
      self.submission_type = form.submission_type
    else
      self.submission_format = form.submission_format
    end

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
