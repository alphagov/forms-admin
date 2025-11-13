namespace :data_migrations do
  desc "Set submission format for forms to match the old style submission type"
  task set_forms_submission_format: :environment do
    [
      ["email", []],
      ["email_with_csv", %w[csv]],
      ["email_with_csv_and_json", %w[csv json]],
      ["email_with_json", %w[json]],
      ["s3", %w[csv]],
      ["s3_with_json", %w[json]],
    ].each do |submission_type, submission_format|
      Form.where(submission_type:).update_all(submission_format:)
      FormDocument.where("content ->> 'submission_type' = ?", submission_type)
        .update_all(content: Arel.sql("jsonb_set(content, '{submission_format}', ?)", submission_format.to_json))
    end
  end

  desc "Change submission type for forms from the old style to the new style"
  task set_forms_submission_type: :environment do
    [
      %w[email_with_csv email],
      %w[email_with_csv_and_json email],
      %w[email_with_json email],
      %w[s3_with_json s3],
    ].each do |old_submission_type, new_submission_type|
      Form.where(submission_type: old_submission_type).update_all(submission_type: new_submission_type)
      FormDocument.where("content ->> 'submission_type' = ?", old_submission_type)
        .update_all(content: Arel.sql("jsonb_set(content, '{submission_type}', ?)", new_submission_type.to_json))
    end
  end
end
