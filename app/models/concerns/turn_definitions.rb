# Define all rules regarding score process
module TurnDefinitions
  MAX_PINS_KNOCKED_DOWN = 10

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

    if pins_knocked_down > MAX_PINS_KNOCKED_DOWN || (shots.sum + pins_knocked_down) > MAX_PINS_KNOCKED_DOWN
      raise StandardError, 'Invalid number of pins knocked down'
    end

    roll_detail['shots'] = shots << pins_knocked_down
    roll_detail['roll_type'] = roll_type(roll_detail['shots'].size, roll_detail['shots'].sum)

    roll_detail
  end
end
