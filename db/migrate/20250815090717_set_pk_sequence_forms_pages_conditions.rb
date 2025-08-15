class SetPkSequenceFormsPagesConditions < ActiveRecord::Migration[8.0]
  def up
    reset_pk_sequence_with_gap!("forms")
    reset_pk_sequence_with_gap!("pages")
    reset_pk_sequence_with_gap!("conditions")
  end

  def down
    set_pk_sequence!("forms", 1)
    set_pk_sequence!("pages", 1)
    set_pk_sequence!("conditions", 1)
  end

private

  def reset_pk_sequence_with_gap!(table)
    max_id = table.classify.constantize.select("max(id)")[0].max || 0
    set_pk_sequence!(table, 10**(max_id.digits.length + 2))
  end
end
