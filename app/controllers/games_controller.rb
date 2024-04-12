# In charge of new Game creations and give the score
class GamesController < ApplicationController
  def create
    start_game
    render json: { game: GameSerializer.new(@game).attributes }, status: :ok
  rescue ActionController::ParameterMissing => e
    render status: :unprocessable_entity, json: { message: e.message }
  end

  private

  def start_game
    create_game
    create_players
    start_first_turn
  end

  def start_first_turn
    @game.turns.first.playing!
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
end
