# Define all rules regarding score process
module TurnDefinitions
  MAX_PINS_KNOCKED_DOWN = 10
  MAX_TURNS = 2

  def roll_type(shots)
    # :normal Not all the pins knocked down with two shots
    # :spare All the pins knocked down in two shots
    # :strike All the pins knocked down in one shot
    return :strike if shots.first == MAX_PINS_KNOCKED_DOWN
    return :spare if shots.sum >= MAX_PINS_KNOCKED_DOWN

    :normal
  end

  def build_roll_detail(turn, pins_knocked_down, last_turn)
    roll_detail = turn.rolls_detail || {}
    shots = roll_detail['shots'] || []

    if invalid_arguments?(last_turn, pins_knocked_down, shots, roll_detail)
      raise ArgumentError, 'Invalid number of pins knocked down'
    end

    roll_detail['shots'] = shots << pins_knocked_down
    roll_detail['roll_type'] = roll_type(roll_detail['shots'])

    roll_detail
  end

  def game_completed?(turns)
    turns.size == MAX_TURNS && turns.map(&:completed).size == MAX_TURNS
  end

  def normal_completed?(rolls_detail)
    normal_turn?(rolls_detail) && shots_completed?(rolls_detail['shots'])
  end

  def normal_score(rolls_detail, current_score)
    current_score + rolls_detail['shots'].sum
  end

  def must_pending_score?(rolls_detail)
    !normal_turn?(rolls_detail)
  end

  def can_score_pending_turn?(last_rolls_detail, all_pending_shots, current_shots)
    return current_shots.size == 1 if spare_turn?(last_rolls_detail)

    (all_pending_shots.size + current_shots.size) > 1
  end

  def score_pending_turn(last_rolls_detail, shots, current_score)
    return current_score + MAX_PINS_KNOCKED_DOWN + shots.first if spare_turn?(last_rolls_detail)

    current_score + MAX_PINS_KNOCKED_DOWN + shots.sum if strike_turn?(last_rolls_detail)
  end

  def last_turn?(turns, current_turn)
    turns.size == MAX_TURNS && current_turn.playing?
  end

  def can_score_last_special_turn?(last_turn, rolls_detail)
    last_turn && rolls_detail['shots'].size == 3
  end

  def score_last_turn(rolls_detail, shots, current_score)
    return score_pending_turn(rolls_detail, [shots.last], current_score) if spare_turn?(rolls_detail)

    score_pending_turn(rolls_detail, shots.last(2), current_score)
  end

  private

  def normal_turn?(rolls_detail)
    rolls_detail['roll_type'] == 'normal'
  end

  def spare_turn?(rolls_detail)
    rolls_detail['roll_type'] == 'spare'
  end

  def strike_turn?(rolls_detail)
    rolls_detail['roll_type'] == 'strike'
  end

  def shots_completed?(shots)
    shots.size == 2
  end

  def exceeds_max_pins?(pins_knocked_down)
    pins_knocked_down > MAX_PINS_KNOCKED_DOWN
  end

  def invalid_arguments?(last_turn, pins_knocked_down, shots, roll_detail)
    return invalid_pins_knocked_down?(pins_knocked_down, shots) unless last_turn

    invalid_pins_for_last_turn?(last_turn, pins_knocked_down, shots, roll_detail)
  end

  def invalid_pins_knocked_down?(pins_knocked_down, shots)
    exceeds_max_pins?(pins_knocked_down) || exceeds_max_pins?(shots.sum + pins_knocked_down) || shots_completed?(shots)
  end

  def invalid_pins_for_last_turn?(last_turn, pins_knocked_down, shots, rolls_detail)
    return false unless last_turn || exceeds_max_pins?(pins_knocked_down) || shots.sum.zero?

    invalid_last_turn_by_type?(pins_knocked_down, shots, rolls_detail)
  end

  def invalid_last_turn_by_type?(pins_knocked_down, shots, rolls_detail)
    return invalid_pins_knocked_down?(pins_knocked_down, shots) if normal_turn?(rolls_detail)

    shots_completed = shots.size == 3
    shots_sum = shots.sum

    # 20 assuming 10 with spare turn and the last MAX 10
    return shots_completed || shots_sum == 20 if spare_turn?(rolls_detail)

    shots_completed || shots_sum == 30 # 30 assuming three strike shots
  end
end
