class AddExitPageFieldsToConditions < ActiveRecord::Migration[8.0]
  def change
    change_table(:conditions, bulk: true) do |t|
      t.column :exit_page_markdown, :text, comment: "When not nil this condition should be treated as an exit page. When set it contains the markdown for the body of the exit page"
      t.column :exit_page_heading, :text, comment: "Text for the heading of the exit page"
    end
  end
end
