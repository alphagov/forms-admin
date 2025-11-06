class AddSubmissionFormatToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :submission_format, :string, array: true
  end
end
