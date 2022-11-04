class CreateFormSubmissionEmail < ActiveRecord::Migration[7.0]
  def change
    create_table :form_submission_emails do |t|
      t.integer :form_id, index: true, foreign_key: true
      t.string :temporary_submission_email
      t.string :confirmation_code
      t.string :created_by_name
      t.string :created_by_email
      t.string :updated_by_name
      t.string :updated_by_email
      t.timestamps
    end
  end
end
