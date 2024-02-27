class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true, index: false, comment: "The user who is a member of the group"
      t.references :group, null: false, foreign_key: true, index: false, comment: "The group that the user is a member of"
      t.references :added_by, null: false, foreign_key: { to_table: :users }, comment: "The user who created the membership"

      t.timestamps

      t.index %i[user_id group_id], unique: true, comment: "Ensure that a user can only be a member of a group once"
    end
  end
end
