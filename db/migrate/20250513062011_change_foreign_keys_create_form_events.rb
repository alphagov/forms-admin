class ChangeForeignKeysCreateFormEvents < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :create_form_events, :groups
    add_foreign_key :create_form_events, :groups, on_delete: :cascade, validate: false

    remove_foreign_key :create_form_events, :users
    add_foreign_key :create_form_events, :users, on_delete: :cascade, validate: false
  end
end
