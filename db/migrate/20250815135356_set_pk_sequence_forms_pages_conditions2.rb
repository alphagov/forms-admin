class SetPkSequenceFormsPagesConditions2 < ActiveRecord::Migration[8.0]
  def up
    reset_pk_sequence_with_gap2!("forms")
    reset_pk_sequence_with_gap2!("pages")
    reset_pk_sequence_with_gap2!("conditions")
  end

  def down
    reset_pk_sequence_with_gap!("forms")
    reset_pk_sequence_with_gap!("pages")
    reset_pk_sequence_with_gap!("conditions")
  end

private

  def reset_pk_sequence_with_gap!(table)
    max_id = table.classify.constantize.select("max(id)")[0].max || 0
    # heuristic to detect whether any records were created since the pk sequence was last changed
    if max_id >= 1_000_000
      set_pk_sequence!(table, max_id)
    else
      set_pk_sequence!(table, 10**(max_id.digits.length + 2))
    end
  end

  def reset_pk_sequence_with_gap2!(table)
    max_id = table.classify.constantize.select("max(id)")[0].max || 0
    set_pk_sequence!(table, 2**(max_id.bit_length + 4))
  end
end
