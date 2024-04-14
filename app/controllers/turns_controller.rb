# In charge of receive each rolls and its data
class TurnsController < ActionController::API
  include TurnDefinitions

  def create
    save_roll
    render json: GameSerializer.new(turn.game).attributes, status: :ok
  rescue StandardError => e
    render status: :unprocessable_entity, json: { message: e.message }
  end

  private

  def save_roll
    turn.update_column(:rolls_detail, (turn.rolls_detail || {}).merge(build_roll_detail(turn, pins_knocked_down)))
  end

  def turn
    @turn ||= Turn.find(turn_identifier)
  end

  def pins_knocked_down
    params.require(:pins_knocked_down).to_i
  end

  def turn_identifier
    params.required(:turn_id)
  end
end
