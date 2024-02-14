class AddExternalIdToGroup < ActiveRecord::Migration[7.1]
  def change
    # Rubcop will complain that we are making a column not null without a default value
    # which wouldn't work if we already had data in the table. We are going to ignore this
    # because we don't have any data in the table yet.

    # rubocop:disable Rails/NotNullColumn
    add_column :groups, :external_id, :text, null: false
    # rubocop:enable Rails/NotNullColumn
    add_index :groups, :external_id, unique: true
  end
end
