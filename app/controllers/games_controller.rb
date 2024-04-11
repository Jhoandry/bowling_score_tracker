# In charge of new Game creations and give the score
class GamesController < ApplicationController
  def create
    render status: :ok, json: { result: 'ok' }
  end

  private

  def permitted_params
    params.permit(:location, :players)
  end
end
