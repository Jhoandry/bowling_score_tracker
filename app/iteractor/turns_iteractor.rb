# Manager of game changes
class TurnsIteractor
  include TurnDefinitions

  attr_reader :turn, :game, :player, :pins_knocked_down

  def initialize(turn_identifier, pins_knocked_down)
    @turn = Turn.find(turn_identifier)
    @game = turn.game
    @player = turn.player
    @pins_knocked_down = pins_knocked_down
  end

  def handle_game_changes
    save_current_roll
    compleate_pending_scoring
    define_status_current_turn

    GameSerializer.new(turn.game).attributes
  end

  private

  def save_current_roll
    turn.update_column(:rolls_detail, (turn.rolls_detail || {}).merge(build_roll_detail(turn, pins_knocked_down)))
  end

  def compleate_pending_scoring
    turn_pending_score = game.turns.find_by_status(:pending_scoring)

    return unless turn_pending_score.present? &&
                  can_score_pending_turn?(turn_pending_score.rolls_detail, turn.rolls_detail)

    turn_pending_score.complete_turn(score_pending_turn(turn_pending_score.rolls_detail, turn.rolls_detail))
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
end
