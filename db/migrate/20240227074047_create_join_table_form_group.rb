class CreateJoinTableFormGroup < ActiveRecord::Migration[7.1]
  def change
    create_join_table :forms, :groups, table_name: :groups_form_ids do |t|
      t.index :group_id
      t.index :form_id, unique: true
    end
  end
end
