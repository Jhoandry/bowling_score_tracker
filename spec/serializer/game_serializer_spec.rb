RSpec.describe GameSerializer do
  subject(:serializer) { described_class.new(game) }

  let(:game) { Game.create }
  let(:firts_player) { Player.create(name: 'test player name') }
  let(:second_player) { Player.create(name: 'test player name') }
  let!(:firts_player_turn) { Turn.create(player: firts_player, game:) }
  let!(:second_player_turn) { Turn.create(player: second_player, game:) }

  describe '#atribute' do
    let(:expected_body) do
      {
        id: game.id,
        location: game.location,
        players: [
          { id: firts_player.id,
            name: firts_player.name,
            turns: [{ number: firts_player_turn.turn_number,
                      score: firts_player_turn.score,
                      status: firts_player_turn.status }],
            total_score: 0 },
          { id: second_player.id,
            name: second_player.name,
            turns: [{ number: second_player_turn.turn_number,
                      score: second_player_turn.score,
                      status: second_player_turn.status }],
            total_score: 0 }
        ]
      }
    end

    it do
      expect(serializer.attributes).to include(:location, :players)
    end

    it do
      expect(serializer.attributes).to match(expected_body)
    end
  end
end
