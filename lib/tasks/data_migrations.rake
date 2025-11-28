namespace :data_migrations do
  desc "Updates form documents to remove the database_id attribute from steps"
  task remove_step_database_ids: :environment do
    form_documents = FormDocument.where("(content -> 'steps' -> 0) ? :key", key: "database_id")
    Rails.logger.info "data_migrations:remove_step_database_ids will update #{form_documents.count} form_documents"

    form_documents.find_each do |form_document|
      form_document.content["steps"].each { |s| s.delete("database_id") }
      form_document.save!
    end

    Rails.logger.info "data_migrations:remove_step_database_ids finished"
  end
end
