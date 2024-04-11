class CreateTurns < ActiveRecord::Migration[7.0]
  def up
    create_table :turns do |t|
      t.integer :turn_number, null: false, default: 1
      t.integer :score
      t.string :status, null: false, default: 'pending'
      t.references :player, null: false
      t.references :game, null: false

      t.timestamps
    end
  end

  def down
    drop_table :turns
  end
end
