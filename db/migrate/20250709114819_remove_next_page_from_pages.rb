class RemoveNextPageFromPages < ActiveRecord::Migration[8.0]
  def change
    remove_column :pages, :next_page, :integer
  end
end
