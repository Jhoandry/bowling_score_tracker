class AddRollsOnTurn < ActiveRecord::Migration[7.0]
  def up
    add_column :turns, :rolls_detail, :json
  end

  def down
    remove_column :turns, :rolls_detail
  end
end
