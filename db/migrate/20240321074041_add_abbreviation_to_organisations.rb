class AddAbbreviationToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :abbreviation, :string
  end
end
