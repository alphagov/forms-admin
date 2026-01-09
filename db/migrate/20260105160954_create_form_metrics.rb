class CreateFormMetrics < ActiveRecord::Migration[8.1]
  def change
    # rubocop:disable  Rails/CreateTableWithTimestamps
    create_table :form_metrics do |t|
      t.references :form, null: false, foreign_key: true
      t.date :date, null: false
      t.string :metric_name, null: false
      t.integer :total, default: 0, null: false
    end
    # rubocop:enable  Rails/CreateTableWithTimestamps

    add_index :form_metrics, %i[form_id date metric_name], unique: true
  end
end
