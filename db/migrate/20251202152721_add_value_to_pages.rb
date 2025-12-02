class AddValueToPages < ActiveRecord::Migration[8.1]
  def change
    # A data migration rake task must be created to update all existing forms in the database.
    # This script will iterate through all selection questions in every FormDocument.
    # For each existing option, it must add the new value field, populating it with the content from the existing name field.
    #todo: is this pages, or page_translations, or draft_questions? or all three. 
    # change_table(:pages, bulk: true) do |t| 
      # t.column :answer_settings,
    # end
  end
end
