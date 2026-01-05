class FormMetric < ApplicationRecord
  belongs_to :form

  validates :date, presence: true
  validates :metric_name, presence: true
  validates :total, presence: true

  def self.increment_started_total!(form_id)
    increment_total_for!(form_id: form_id, metric_name: "started")
  end

  def self.increment_submitted_total!(form_id)
    increment_total_for!(form_id: form_id, metric_name: "submitted")
  end

  def self.increment_total_for!(form_id:, metric_name:)
    conn = connection
    table = conn.quote_table_name(table_name)
    date  = Time.zone.now.utc.to_date

    # Using ON CONFLICT DO UPDATE guarantees atomicity for concurrent increments
    sql = <<~SQL
      INSERT INTO #{table} (form_id, date, metric_name, total)
      VALUES (#{conn.quote(form_id)}, #{conn.quote(date)}, #{conn.quote(metric_name)}, 1)
      ON CONFLICT (form_id, date, metric_name)
      DO UPDATE SET total = #{table}.total + 1
    SQL

    conn.exec_query(sql)
  end
end
