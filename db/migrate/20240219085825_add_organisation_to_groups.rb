class AddOrganisationToGroups < ActiveRecord::Migration[7.1]
  def change
    add_reference :groups, :organisation
  end
end
