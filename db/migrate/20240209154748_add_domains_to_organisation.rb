class AddDomainsToOrganisation < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :domains, :string, array: true, default: []
  end
end
