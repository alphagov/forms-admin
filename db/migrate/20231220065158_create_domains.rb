class CreateDomains < ActiveRecord::Migration[7.0]
  def change
    create_table :domains do |t|
      t.string :domain
      t.references :organisation, null: true, foreign_key: true

      t.timestamps
    end
  end
end
