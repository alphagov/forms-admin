class Forms::DailySubmissionBatchInput < BaseInput
  attr_accessor :form, :send_daily_submission_batch

  def submit
    form.send_daily_submission_batch = ActiveModel::Type::Boolean.new.cast(send_daily_submission_batch)
    form.save_draft!
  end

  def assign_form_values
    self.send_daily_submission_batch = form.send_daily_submission_batch
    self
  end
end
