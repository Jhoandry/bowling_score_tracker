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
          turns: player.turns.map { |turn| { number: turn.turn_number, score: turn.score, status: turn.status } },
          total_score: total_score(player) }
      end
    }
  end

  private

  def total_score(player)
    player.turns.pluck(:score).compact.sum
  end
end
