class SetEnToExistingForms < ActiveRecord::Migration[8.0]
  class Form < ApplicationRecord
  end

  def change
    Form.where(language: nil).update_all(language: %w[en])
  end
end
