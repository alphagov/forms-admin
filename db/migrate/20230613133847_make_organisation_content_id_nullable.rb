class MakeOrganisationContentIdNullable < ActiveRecord::Migration[7.0]
  def change
    rename_column(:organisations, :content_id, :govuk_content_id)
    change_column_null(:organisations, :govuk_content_id, true)
  end
end
