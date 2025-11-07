namespace :data_migrations do
  desc "Set submission type for forms to match the old style submission format"
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
end
