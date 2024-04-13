# == Schema Information
#
# Table name: turns
#
#  id           :bigint           not null, primary key
#  rolls_detail :json
#  score        :integer
#  status       :string           default("pending"), not null
#  turn_number  :integer          default(1), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  game_id      :bigint           not null
#  player_id    :bigint           not null
#
# Indexes
#
#  index_turns_on_game_id    (game_id)
#  index_turns_on_player_id  (player_id)
#
class Turn < ApplicationRecord
  belongs_to :game
  belongs_to :player

  state_machine :status, initial: :pending do
    state :playing
    state :pending_scoring
    state :canceled
    state :completed

    event :cancel do
      transition %i[pending playing pending_scoring] => :canceled
    end

    event :playing do
      transition pending: :playing
    end

    event :pending_scoring do
      transition playing: :pending_scoring
    end

    event :completed do
      transition %i[playing pending_scoring] => :completed
    end
  end
end
