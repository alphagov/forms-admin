require "json"
require "net/http"

class AddOrganisationRefToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :organisation, null: true, foreign_key: true
  end
end
