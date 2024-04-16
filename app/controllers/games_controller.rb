# In charge of new Game creations and give the score
class GamesController < ActionController::API
  def create
    render json: start_game, status: :ok
  rescue ActionController::ParameterMissing => e
    render status: :unprocessable_entity, json: { message: e.message }
  end

  def index
    render json: game_by_identifier, status: :ok
  rescue StandardError => e
    render status: :unprocessable_entity, json: { message: e.message }
  end

  private

  def game_by_identifier
    return Rails.cache.read("GAME_#{game_identifier}") if Rails.cache.read("GAME_#{game_identifier}")

    stash_game_changes_on_cache(Game.find(game_identifier))
  end

  def start_game
    create_game
    create_players
    start_first_turn
    stash_game_changes_on_cache(@game)
  end

  def stash_game_changes_on_cache(game)
    game_serializer = GameSerializer.new(game).attributes
    Rails.cache.write("GAME_#{game.id}", game_serializer)

    game_serializer
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

  def game_identifier
    params.required(:id)
  end

  def permitted_params
    params.permit(:location, players: [])
  end
end
