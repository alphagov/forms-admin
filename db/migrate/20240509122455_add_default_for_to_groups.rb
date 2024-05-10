class AddDefaultForToGroups < ActiveRecord::Migration[7.1]
  def change
    add_reference :groups, :default_for, polymorphic: true
  end
end
