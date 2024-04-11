class CreatePlayers < ActiveRecord::Migration[7.0]
  def up
    create_table :players do |t|
      t.string :name, null: false, default: 'Default player'
    end
  end

  def down
    drop_table :players
  end
end
