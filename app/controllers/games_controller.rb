# In charge of new Game creations and give the score
class GamesController < ApplicationController
  def create
    start_game
    render json: { game: serialize_game }, status: :ok
  rescue ActionController::ParameterMissing => e
    render status: :unprocessable_entity, json: { message: e.message }
  end

  private

  def start_game
    create_game
    create_players
  end

  def create_players
    player_names.each do |player_name|
      player = Player.create(name: player_name)
      Turn.create(player:, game: @game)
    end
  end

  def create_game
    @game = Game.create({ location: }.compact)
  end

  def location
    permitted_params[:location]
  end

  def player_names
    params.required(:players)
  end

  def permitted_params
    params.permit(:location, players: [])
  end

  def serialize_game
    {
      id: @game.id,
      location: @game.location,
      players: @game.players.map do |player|
        { id: player.id,
          name: player.name,
          turns: player.turns.map { |turn| { number: turn.turn_number, score: turn.score, status: turn.status } } }
      end
    }
  end
end
