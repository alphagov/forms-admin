class Forms::BatchSubmissionsInput < BaseInput
  attr_accessor :form, :batch_frequencies

  def submit
    form.send_daily_submission_batch = batch_frequencies.include?("daily")
    form.send_weekly_submission_batch = batch_frequencies.include?("weekly")
    form.save_draft!
  end

  def assign_form_values
    self.batch_frequencies ||= []
    self.batch_frequencies << "daily" if form.send_daily_submission_batch
    self.batch_frequencies << "weekly" if form.send_weekly_submission_batch
    self
  end
end
