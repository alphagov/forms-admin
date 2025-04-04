class AddInternalToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :internal, :boolean, default: false
  end
end
