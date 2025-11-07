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

  desc "Set external ID for pages where one does not exist"
  task set_page_external_ids: :environment do
    updated_page_count = 0
    Page.where(external_id: nil).find_each do |page|
      page.update!(external_id: ExternalIdProvider.generate_unique_id_for(Page))
      updated_page_count += 1
    end

    Rails.logger.info "data_migrations:set_page_external_ids updated #{updated_page_count} pages"

    updated_form_document_count = 0
    FormDocument.find_each do |form_document|
      steps_updated = false
      form_document.content["steps"].each do |step|
        next if step["external_id"].present?

        # A page record might no longer exist for a step if it's been deleted in the draft
        page = Page.find_by(id: step["id"])
        step["external_id"] = if page
                                page.external_id
                              else
                                ExternalIdProvider.generate_unique_id_for(Page)
                              end
        steps_updated = true
      end

      if steps_updated
        form_document.save!
        updated_form_document_count += 1
      end
    end

    Rails.logger.info "data_migrations:set_page_external_ids updated #{updated_form_document_count} form_documents"
  end
end
