class CreateRolls < ActiveRecord::Migration[7.0]
  def up
    create_table :rolls do |t|
      t.integer :chance, null: false, default: 1
      t.integer :pins_knocked_down, null: false, default: 0
      t.string :type, null: false, default: 'normal'
      t.references :turn, null: false

      t.timestamps
    end
  end

  def down
    drop_table :rolls
  end
end
