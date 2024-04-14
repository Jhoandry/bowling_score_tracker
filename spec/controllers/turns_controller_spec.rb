RSpec.describe TurnsController do
  let(:game) { Game.create }
  let(:firts_player) { Player.create(name: 'test player name') }
  let!(:firts_player_turn) { Turn.create(player: firts_player, game:, status: :playing) }

  describe '#create' do
    subject(:create) { post :create, format: :json, params: score_body }

    let(:score_body) { { turn_id: firts_player_turn.id, pins_knocked_down: } }
    let(:expected_rolls_detail) { { roll_type:, shots: } }

    context 'when palyer shot nolmal roll' do
      let(:pins_knocked_down) { 4 }
      let(:roll_type) { 'normal' }
      let(:shots) { [pins_knocked_down] }

      it do
        expect(create).to have_http_status(:ok)
      end

      it 'turn must contain rolls_details data' do
        create
        firts_player_turn.reload
        expect(firts_player_turn.rolls_detail.deep_symbolize_keys).to include(expected_rolls_detail)
      end
    end

    context 'when spare turn' do
      let(:pins_knocked_down) { 5 }
      let(:roll_type) { 'spare' }
      let(:shots) { [pins_knocked_down, pins_knocked_down] }

      before do
        firts_player_turn.update_column(:rolls_detail, {
                                          roll_type: :normal,
                                          shots: [pins_knocked_down]
                                        })
      end

      it do
        expect(create).to have_http_status(:ok)
      end

      it 'turn must contain rolls_details data with spare roll_type' do
        create
        firts_player_turn.reload
        expect(firts_player_turn.rolls_detail.deep_symbolize_keys).to include(expected_rolls_detail)
      end

      it 'starts new turn' do
        create
        firts_player.reload
        expect(firts_player.turns.size).to eq(2)
      end

      it 'last turn should be pending_scoring' do
        create
        firts_player_turn.reload
        expect(firts_player_turn.status).to eq('pending_scoring')
      end
    end

    context 'when strike turn' do
      let(:pins_knocked_down) { 10 }
      let(:roll_type) { 'strike' }
      let(:shots) { [pins_knocked_down] }

      it do
        expect(create).to have_http_status(:ok)
      end

      it 'turn must contain rolls_details data with strike roll_type' do
        create
        firts_player_turn.reload
        expect(firts_player_turn.rolls_detail.deep_symbolize_keys).to include(expected_rolls_detail)
      end

      it 'starts new turn' do
        create
        firts_player.reload
        expect(firts_player.turns.size).to eq(2)
      end

      it 'last turn should be pending_scoring' do
        create
        firts_player_turn.reload
        expect(firts_player_turn.status).to eq('pending_scoring')
      end
    end

    context 'when invalid pins_knocked_down' do
      let(:pins_knocked_down) { 11 }

      it do
        expect(create).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when invalid pins_knocked_down on second shot' do
      let(:pins_knocked_down) { 7 }

      before do
        firts_player_turn.update_column(:rolls_detail, {
                                          roll_type: :normal,
                                          shots: [pins_knocked_down]
                                        })
      end

      it do
        expect(create).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
