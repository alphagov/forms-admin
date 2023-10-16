class CreateMouSignatures < ActiveRecord::Migration[7.0]
  def change
    create_table :mou_signatures,
                 comment: "User signatures of an MOU for an oragnisation" do |t|
      t.references :user, null: false,
                          foreign_key: true,
                          comment: "User who signed MOU"

      t.references :organisation, null: true,
                                  foreign_key: true,
                                  comment: "Organisation which user signed MOU on behalf of, or null"

      t.datetime :agreed_at, null: false,
                             comment: "The datetime of the signature"

      t.timestamps null: false
    end

    add_index :mou_signatures,
              %i[user_id organisation_id],
              unique: true,
              comment: "Users can only sign an MOU for an Organisation once"

    add_index :mou_signatures,
              :user_id,
              where: "organisation_id IS NULL",
              unique: true,
              name: "index_mou_signatures_on_user_id_unique_without_organisation_id",
              comment: "Users can only sign a single MOU without an organisation"
  end
end
