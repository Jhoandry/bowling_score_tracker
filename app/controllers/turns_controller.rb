# In charge of receive each rolls and its data
class TurnsController < ActionController::API
  def create
    render json: TurnsIteractor.new(turn_identifier, pins_knocked_down).handle_game_changes, status: :ok
  rescue StandardError => e
    render status: :unprocessable_entity, json: { message: e.message }
  end

  private

  def pins_knocked_down
    params.require(:pins_knocked_down).to_i
  end

  def turn_identifier
    params.required(:turn_id)
  end
end
