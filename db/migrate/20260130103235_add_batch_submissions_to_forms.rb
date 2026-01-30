class AddBatchSubmissionsToForms < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :batch_submissions, :boolean, default: false
  end
end
