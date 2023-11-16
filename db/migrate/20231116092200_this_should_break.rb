class ThisShouldBreakWrongName < ActiveRecord::Migration[7.0]
  def change
    say "The name of this migration does not match that in db/migrate"
  end
end
