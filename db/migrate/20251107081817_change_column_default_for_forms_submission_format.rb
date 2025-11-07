class ChangeColumnDefaultForFormsSubmissionFormat < ActiveRecord::Migration[8.0]
  def change
    change_column_default :forms, :submission_format, from: nil, to: []
  end
end
