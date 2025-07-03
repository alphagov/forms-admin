class RemoveDefaultGroupIdFromOrganisations < ActiveRecord::Migration[8.0]
  def change
    remove_column :organisations, :default_group_id, :bigint
  end
end
