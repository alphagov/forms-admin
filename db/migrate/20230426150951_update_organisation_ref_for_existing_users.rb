require "json"
require "net/http"

class UpdateOrganisationRefForExistingUsers < ActiveRecord::Migration[7.0]
  def up
    # For each user created by gds-sso, link to a record in organisation table.
    User.where.not(organisation_content_id: nil).find_each do |user|
      organisation = Organisation.find_by(content_id: user.organisation_content_id)
      user.update!(organisation_id: organisation.id)
    end
  end
end
