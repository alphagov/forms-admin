class AddSendWeeklySubmissionBatchToForms < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :send_weekly_submission_batch, :boolean, default: false
  end
end
