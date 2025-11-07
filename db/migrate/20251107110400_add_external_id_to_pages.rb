class AddExternalIdToPages < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :external_id, :string
    add_index :pages, :external_id, unique: true
  end
end
