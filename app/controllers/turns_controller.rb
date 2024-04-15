# In charge of receive each rolls and its data
class TurnsController < ActionController::API
  include TurnDefinitions

  def create
    save_roll
    handle_game_changes
    render json: GameSerializer.new(turn.game).attributes, status: :ok
  rescue StandardError => e
    render status: :unprocessable_entity, json: { message: e.message }
  end

  private

  def save_roll
    turn.update_column(:rolls_detail, (turn.rolls_detail || {}).merge(build_roll_detail(turn, pins_knocked_down)))
  end

  def handle_game_changes
    compleate_pending_scoring
    define_status_current_turn
  end

  def compleate_pending_scoring
    turn_pending_score = game.turns.find_by_status(:pending_scoring)

    return unless turn_pending_score.present? &&
                  can_score_pending_turn?(turn_pending_score.rolls_detail, turn.rolls_detail)

    have_pending_score.complete_turn(score_pending_turn(turn_pending_score.rolls_detail, turn.rolls_detail))
  end

  def define_status_current_turn
    normal_completed = normal_completed?(turn.rolls_detail)
    must_pending_score = must_pending_score?(turn.rolls_detail)

    return unless normal_completed || must_pending_score

    # normal turn with two shots
    turn.complete_turn(normal_score(turn.rolls_detail)) if normal_completed

    # Striker or Spare turns must wait next turn to be scored
    turn.pending_scoring! if must_pending_score
    handle_next_player
  end

  def handle_next_player
    init_turn_for_current_player
    start_next_player
  end

  def start_next_player
    game.turns.find_by_status(:pending).playing!
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
