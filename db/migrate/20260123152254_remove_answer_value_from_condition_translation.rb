class RemoveAnswerValueFromConditionTranslation < ActiveRecord::Migration[8.1]
  def change
    remove_column :condition_translations, :answer_value, :string
  end
end
