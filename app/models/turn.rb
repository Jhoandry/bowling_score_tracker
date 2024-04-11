# == Schema Information
#
# Table name: turns
#
#  id          :bigint           not null, primary key
#  score       :integer
#  turn_number :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  game_id     :bigint           not null
#  player_id   :bigint           not null
#
# Indexes
#
#  index_turns_on_game_id    (game_id)
#  index_turns_on_player_id  (player_id)
#
class Turn < ApplicationRecord
  belongs_to :game
  belongs_to :player
  has_many :rolls, dependent: :destroy
end
