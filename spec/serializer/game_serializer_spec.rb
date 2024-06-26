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
          { name: firts_player.name,
            turns: [{ identifier: firts_player_turn.id,
                      shots: [],
                      type: nil,
                      score: 0,
                      status: firts_player_turn.status }],
            total_score: 0 },
          { name: second_player.name,
            turns: [{ identifier: second_player_turn.id,
                      shots: [],
                      type: nil,
                      score: 0,
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
