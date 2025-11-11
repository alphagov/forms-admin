class Forms::SubmissionFormatInput < BaseInput
  attr_accessor :form, :submission_format

  validates :submission_format, presence: true

  def submit
    return false if invalid?

    form.submission_format = submission_format
    form.save_draft!
  end

  def assign_form_values
    self.submission_format = form.submission_format
    self
  end

  def submission_formats
    return nil if submission_format.nil?
    return [] if submission_type == "email"

    formats = []
    formats << "csv" if submission_type.include? "csv"
    formats
  end

  def checked
    return nil if submission_format.nil?

    Form.submission_formats.each_key.map { |format|
      [format, submission_format.include?(format)]
    }.to_h
  end

  def submission_formats=(formats)
    self.submission_type = if formats.nil?
                             nil
                           else
                             formats.include?("csv") ? "email_with_csv" : "email"
                           end
  end
end
