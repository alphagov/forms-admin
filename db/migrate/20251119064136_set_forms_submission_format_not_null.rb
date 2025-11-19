class SetFormsSubmissionFormatNotNull < ActiveRecord::Migration[8.0]
  def change
    add_check_constraint :forms, "submission_format IS NOT NULL", name: "forms_submission_format_is_not_null", validate: false
  end
end
