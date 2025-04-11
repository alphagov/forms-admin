class CreateCreateFormEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :create_form_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.string :form_name, null: false
      t.references :form, index: false
      t.integer :dedup_version

      t.timestamps
    end

    add_index :create_form_events, %i[group_id form_name dedup_version], unique: true
  end
end
