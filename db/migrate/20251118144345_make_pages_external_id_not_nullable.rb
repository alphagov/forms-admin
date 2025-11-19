class MakePagesExternalIdNotNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null(:pages, :external_id, false)
  end
end
