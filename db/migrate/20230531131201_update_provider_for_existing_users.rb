class UpdateProviderForExistingUsers < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord; end

  def up
    User.where.not(uid: nil).update_all(provider: :gds) # currently we only have one provider
  end

  def down
    User.update_all(provider: nil)
  end
end
