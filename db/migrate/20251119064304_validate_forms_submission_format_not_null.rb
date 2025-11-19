class ValidateFormsSubmissionFormatNotNull < ActiveRecord::Migration[8.0]
  def up
    validate_check_constraint :forms, name: "forms_submission_format_is_not_null"
    change_column_null :forms, :submission_format, false
    remove_check_constraint :forms, name: "forms_submission_format_is_not_null"
  end

  def down
    add_check_constraint :forms, "submission_format IS NOT NULL", name: "forms_submission_format_is_not_null"
    change_column_null :forms, :submission_format, true
  end
end
