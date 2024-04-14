# In charge of receive each rolls and its data
class TurnsController < ActionController::API
  include TurnDefinitions

  def create
    save_roll
    handle_changes
    render json: GameSerializer.new(turn.game).attributes, status: :ok
  rescue StandardError => e
    render status: :unprocessable_entity, json: { message: e.message }
  end

  private

  def save_roll
    turn.update_column(:rolls_detail, (turn.rolls_detail || {}).merge(build_roll_detail(turn, pins_knocked_down)))
  end

  def handle_changes
    can_completed = can_completed?(turn.rolls_detail)
    must_pending_score = must_pending_score?(turn.rolls_detail)

    return unless can_completed || must_pending_score

    # normal turn with two shots
    turn.complete_turn(total_socore(turn.rolls_detail)) if can_completed
    # Striker or Spare turns must wait next turn to be scored
    turn.pending_scoring! if must_pending_score

    update_game
  end

  def update_game
    init_turn_for_current_player
    start_player_with_next_turn
  end

  def start_player_with_next_turn
    game.turns.next_player.playing!
  end

  def init_turn_for_current_player
    Turn.create(game:, player:)
  end

  def pins_knocked_down
    params.require(:pins_knocked_down).to_i
  end

  def turn_identifier
    params.required(:turn_id)
  end

  def turn
    @turn ||= Turn.find(turn_identifier)
  end

  def player
    @player ||= turn.player
  end

  def game
    @game ||= turn.game
  end
end
