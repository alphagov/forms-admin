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

  desc "Set external ID for pages where one does not exist"
  task set_page_external_ids: :environment do
    updated_page_count = 0
    Page.where(external_id: nil).find_each do |page|
      page.update!(external_id: ExternalIdProvider.generate_unique_id_for(Page))
      updated_page_count += 1
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.warn("Failed to update page #{page.id}: #{e.message}")
    end

    Rails.logger.info "data_migrations:set_page_external_ids updated #{updated_page_count} pages"
  end

  desc "Updates form documents to use page external IDs instead of database IDs and adds a temporary database_id attribute."
  task update_form_documents_to_use_external_ids: :environment do
    updated_form_document_count = 0
    FormDocument.find_each do |form_document|
      steps = form_document.content["steps"]

      # skip if form_document has already been updated to use external IDs
      next if steps.empty? || steps.any? { |step| step["database_id"].present? }

      step_ids = steps.map { |s| s["id"] }
      pages_by_id = Page.where(id: step_ids).index_by(&:id)
      step_external_ids = step_ids.each_with_object({}) do |step_id, map|
        page = pages_by_id[step_id]
        map[step_id] = page ? page.external_id : ExternalIdProvider.generate_unique_id_for(Page)
      end

      steps.each do |step|
        id = step["id"]
        step["database_id"] = id
        step["id"] = step_external_ids[id]
        step["next_step_id"] = step_external_ids[step["next_step_id"]] if step["next_step_id"].present?
        step["routing_conditions"].each do |condition|
          condition["routing_page_id"] = step_external_ids[condition["routing_page_id"]] if condition["routing_page_id"].present?
          condition["check_page_id"] = step_external_ids[condition["check_page_id"]] if condition["check_page_id"].present?
          condition["goto_page_id"] = step_external_ids[condition["goto_page_id"]] if condition["goto_page_id"].present?
        end
      end

      form_document.content["start_page"] = steps.first["id"]

      form_document.save!
      updated_form_document_count += 1
    end

    Rails.logger.info "data_migrations:set_page_external_ids updated #{updated_form_document_count} form_documents"
  end
end
