class AddSendDailySubmissionBatchToForms < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :send_daily_submission_batch, :boolean, default: false
  end
end
