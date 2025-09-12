class AddContactForResearchToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table(:users, bulk: true) do |t|
      t.column :research_contact_status, :string, default: "to_be_asked"
      t.column :user_research_opted_in_at, :datetime
    end
  end
end
