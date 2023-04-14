class AddProviderToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :provider, :string # name of OmniAuth provider

    User.where.not(uid: nil).find_each do |user|
      user.update!(provider: :gds)
    end
  end

  def down
    remove_column :users, :provider, :string
  end
end
