class DeleteNumberOfTurn < ActiveRecord::Migration[7.0]
  def change
    remove_column :turns, :turn_number
  end
end
