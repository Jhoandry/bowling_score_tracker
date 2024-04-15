# Returns the necesary data to UI Responses
class GameSerializer
  def initialize(game)
    @game = game
  end

  def attributes
    {
      id: @game.id,
      location: @game.location,
      players: game_players.map do |player|
        { name: player.name,
          turns: player_turs(player),
          total_score: total_score(player) }
      end
    }
  end

  private

  def game_players
    @game.players.order(:id).uniq
  end

  def tunrs_by_player(player)
    player.turns.order(:id)
  end

  def player_turs(player)
    tunrs_by_player(player).map do |turn|
      { identifier: turn.id,
        shots: turn.rolls_detail&.dig('shots') || [],
        type: turn.rolls_detail&.dig('roll_type'),
        score: turn.score || 0,
        status: turn.status }
    end
  end

  def total_score(player)
    tunrs_by_player(player).select { |turn| turn.status == 'completed' }.last&.score || 0
  end
end
