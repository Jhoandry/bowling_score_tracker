class AddStatusIndexOnTurn < ActiveRecord::Migration[7.0]
  def up
    add_index :turns, :status
  end

  def down
    remove_index :turns, :status
  end
end
