# Define all rules regarding score process
module TurnDefinitions
  MAX_PINS_KNOCKED_DOWN = 10
  MAX_TURNS = 10

  def roll_type(shots_count, total_pins_knocked_down)
    # :normal Not all the pins knocked down with two shots
    # :spare All the pins knocked down in two shots
    # :strike All the pins knocked down in one shot
    return :strike if shots_count == 1 && total_pins_knocked_down == MAX_PINS_KNOCKED_DOWN
    return :spare if shots_count > 1 && total_pins_knocked_down == MAX_PINS_KNOCKED_DOWN

    :normal
  end

  def build_roll_detail(turn, pins_knocked_down)
    roll_detail = turn.rolls_detail || {}
    shots = roll_detail['shots'] || []

    if pins_knocked_down > MAX_PINS_KNOCKED_DOWN ||
       (shots.sum + pins_knocked_down) > MAX_PINS_KNOCKED_DOWN || shots_completed?(shots)
      raise ArgumentError, 'Invalid number of pins knocked down'
    end

    roll_detail['shots'] = shots << pins_knocked_down
    roll_detail['roll_type'] = roll_type(roll_detail['shots'].size, roll_detail['shots'].sum)

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
end
