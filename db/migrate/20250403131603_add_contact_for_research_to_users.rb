class AddContactForResearchToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :research_contact_status, :string, default: "not_asked"
  end
end
