# In charge of new Game creations and give the score
class GamesController < ApplicationController
  def create
    if start_game
      render json: { game: serialize_game }, status: :ok
    else
      render json: { error: 'Failed to start the game' }, status: :unprocessable_entity
    end
  end

  private

  def start_game
    return false if player_names.empty?

    @players = create_players
    @game = create_game
    @players.present? && @game.present?
  end

  def create_players
    player_names.map { |player_name| Player.create(name: player_name) }
  end

  def create_game
    Game.create({ location: }.compact)
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
      players: @players.map { |player| { id: player.id, name: player.name } }
    }
  end
end
