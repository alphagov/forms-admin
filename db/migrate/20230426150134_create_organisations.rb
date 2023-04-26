class CreateOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :organisations do |t|
      t.string :content_id, null: false
      t.string :slug, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :organisations, :content_id, unique: true
    add_index :organisations, :slug, unique: true
  end
end
