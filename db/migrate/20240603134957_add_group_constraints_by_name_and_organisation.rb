class AddGroupConstraintsByNameAndOrganisation < ActiveRecord::Migration[7.1]
  def change
    add_index(:groups, %i[name organisation_id], unique: true)
  end
end
