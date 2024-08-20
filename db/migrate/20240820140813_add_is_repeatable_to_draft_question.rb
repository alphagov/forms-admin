class AddIsRepeatableToDraftQuestion < ActiveRecord::Migration[7.1]
  def change
    add_column :draft_questions, :is_repeatable, :boolean
  end
end
