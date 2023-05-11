class UpdateOrganisationRefForExistingUsers2 < ActiveRecord::Migration[7.0]
  def up
    # NOTE: Postgres specific SQL
    execute <<-SQL
      UPDATE users
        SET organisation_id = organisations.id
      FROM organisations
          WHERE organisations.content_id = users.organisation_content_id;
    SQL
  end

  def down
    execute <<-SQL
      UPDATE users
        SET organisation_id = NULL;
    SQL
  end
end
