class CreateGames < ActiveRecord::Migration[7.0]
  def up
    create_table :games do |t|
      t.string :location, null: false, default: 'Freeletics'
      t.timestamps
    end
  end

  def down
    drop_table :games
  end
end
