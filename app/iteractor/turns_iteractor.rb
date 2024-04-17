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
    raise ArgumentError, 'Game is already finalized' if game.all_turns_completed?

    save_current_roll
    compleate_pending_scoring
    define_current_turn_status unless last_turn
    define_last_turn_status if last_turn
    stash_game_changes_on_cache
  end

  private

  def save_current_roll
    turn.update_column(:rolls_detail,
                       (turn.rolls_detail || {}).merge(build_roll_detail(turn, pins_knocked_down, last_turn)))
  end

  def compleate_pending_scoring
    turns_pending_scoring ||= player.turns.where(status: :pending_scoring)

    return if turns_pending_scoring.empty?

    pending_scoring = turns_pending_scoring.first
    shots_pending_scoring = shots_pending_scoring(pending_scoring, turns_pending_scoring)
    define_scoring_pending(pending_scoring, shots_pending_scoring)
    compleate_pending_scoring unless pending_scoring.pending_scoring?
  end

  def define_scoring_pending(pending_scoring, shots_pending_scoring)
    return unless can_score_pending_turn?(pending_scoring.rolls_detail,
                                          shots_pending_scoring,
                                          turn.rolls_detail['shots'])

    pending_scoring.complete_turn(score_pending_turn(pending_scoring.rolls_detail,
                                                     shots_pending_scoring.concat(turn.rolls_detail['shots']),
                                                     current_score))
  end

  def define_current_turn_status
    normal_completed = normal_completed?(turn.rolls_detail)
    must_pending_score = must_pending_score?(turn.rolls_detail)

    return unless normal_completed || must_pending_score

    handle_normal_turn_completed if normal_completed

    # Striker or Spare turns must wait next turn to be scored
    turn.pending_scoring! if must_pending_score
    handle_next_player
  end

  def define_last_turn_status
    handle_normal_turn_completed if normal_completed?(turn.rolls_detail)

    return unless can_score_last_special_turn?(last_turn, turn.rolls_detail)

    turn.complete_turn(score_last_turn(turn.rolls_detail,
                                       turn.rolls_detail['shots'],
                                       current_score))
    handle_next_player
  end

  def stash_game_changes_on_cache
    game_serializer = GameSerializer.new(turn.game).attributes

    if game.all_turns_completed?
      Rails.cache.delete("GAME_#{game.id}", game_serializer)
    else
      Rails.cache.fetch("GAME_#{game.id}") { game_serializer }
    end

    game_serializer
  end

  def handle_next_player
    init_turn_for_current_player
    start_next_player
  end

  def start_next_player
    game.turns.where(status: :pending).order(id: :asc)&.first&.playing!
  end

  def init_turn_for_current_player
    return if game_completed?(player.turns)

    Turn.create(game:, player:)
  end

  def handle_normal_turn_completed
    # normal turn with two shots
    turn.complete_turn(normal_score(turn.rolls_detail, current_score))
  end

  def shots_pending_scoring(current_turn_scoring, turns_pending_scoring)
    turns_pending_scoring.excluding(current_turn_scoring)
                         .map { |turn| turn.rolls_detail['shots'] }
                         .flatten
  end

  def current_score
    player.turns.where(status: :completed).last&.score || 0
  end

  def last_turn
    @last_turn ||= last_turn?(player.turns, turn)
  end
end
