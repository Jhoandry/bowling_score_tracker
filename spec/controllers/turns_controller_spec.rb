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

    context 'when multiple turns' do
      let(:score_body) { { turn_id: second_turn.id, pins_knocked_down:, status: :playing } }
      let!(:second_turn) { Turn.create(player: firts_player, game:, status: :playing) }

      context 'with last turn normal roll_type' do
        let(:pins_knocked_down) { 4 }
        let(:roll_type) { 'normal' }
        let(:shots) { [pins_knocked_down, pins_knocked_down] }

        before do
          second_turn.update_column(:rolls_detail, { roll_type:, shots: [pins_knocked_down] })
          firts_player_turn.update_column(:rolls_detail, { roll_type:, shots: })
          firts_player_turn.update_column(:score, shots.sum)
          firts_player_turn.completed!

          # call create request and reload second_turn turns
          create
          second_turn.reload
        end

        it do
          expect(second_turn.status).to include('completed')
        end

        it do
          expect(second_turn.score).to eq(firts_player_turn.score + shots.sum)
        end
      end

      context 'with last turn spare roll_type' do
        let(:pins_knocked_down) { 4 }

        before do
          firts_player_turn.update_column(:rolls_detail, { roll_type: 'spare', shots: [6, pins_knocked_down] })
          firts_player_turn.pending_scoring!

          # call create request and reload both turns
          create
          firts_player_turn.reload
        end

        it do
          expect(firts_player_turn.status).to include('completed')
        end

        it do
          create
          firts_player_turn.reload
          expect(firts_player_turn.score).to eq(14) # 14 because spare score is 10 pins + first of the current turn
        end

        it do
          create
          second_turn.reload
          expect(second_turn.status).to include('playing')
        end
      end

      context 'with last turn strike roll_type' do
        let(:pins_knocked_down) { 4 }

        before do
          second_turn.update_column(:rolls_detail, { roll_type: 'normal', shots: [pins_knocked_down] })
          firts_player_turn.update_column(:rolls_detail, { roll_type: 'strike', shots: [10] })
          firts_player_turn.pending_scoring!

          # call create request and reload both turns
          create
          firts_player_turn.reload
          second_turn.reload
        end

        it do
          expect(firts_player_turn.status).to include('completed')
        end

        it do
          expect(firts_player_turn.score).to eq(18) # 18 because strike score is 10 pins + SUM of all rolls current turn
        end

        it do
          expect(second_turn.status).to include('completed')
        end

        it 'is the sum of both turn' do
          expect(second_turn.score).to eq(firts_player_turn.score + pins_knocked_down + pins_knocked_down)
        end
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

    context 'when invalid turn identifier' do
      let(:score_body) { { turn_id: 0, pins_knocked_down: 0 } }

      it do
        expect(create).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
