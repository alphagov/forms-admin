class ValidateForeignKeysCreateFormEvents < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :create_form_events, :groups
    validate_foreign_key :create_form_events, :users
  end
end
