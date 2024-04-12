# Returns the necesary data to UI Responses
class GameSerializer
  def initialize(game)
    @game = game
  end

  def attributes
    {
      id: @game.id,
      location: @game.location,
      players: @game.players.map do |player|
        { id: player.id,
          name: player.name,
          turns: player_turs(player),
          total_score: total_score(player) }
      end
    }
  end

  private

  def player_turs(player)
    player.turns.map do |turn|
      { number: turn.turn_number,
        score: turn.score || 0,
        status: turn.status }
    end
  end

  def total_score(player)
    player.turns.pluck(:score).compact.sum
  end
end
