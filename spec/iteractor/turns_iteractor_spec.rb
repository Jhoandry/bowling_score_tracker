RSpec.describe TurnsIteractor do
  subject(:iteractor) { described_class.new(turn_identifier, pins_knocked_down) }

  let(:game) { Game.create }
  let(:player) { Player.create(name: 'test player name') }
  let!(:turn) { Turn.create(player:, game:, status: :playing) }

  describe '#initialize' do
    context 'when invalid turn identifer' do
      let(:turn_identifier) { 0 }
      let(:pins_knocked_down) { 0 }

      it do
        expect { iteractor }.to raise_error(ActiveRecord::RecordNotFound,
                                            "Couldn't find Turn with 'id'=#{turn_identifier}")
      end
    end
  end

  describe '#compleate_pending_scoring' do
    let(:second_turn) { Turn.create(player:, game:, status: :playing) }
    let(:turn_identifier) { second_turn.id }
    let(:pins_knocked_down) { 3 }

    context 'when :strike turn' do
      before do
        second_turn.update_column(:rolls_detail, { roll_type: :normal, shots: [pins_knocked_down, pins_knocked_down] })
        turn.update_column(:rolls_detail, { roll_type: :strike, shots: [10] })
        turn.pending_scoring!
      end

      it do
        iteractor.send(:compleate_pending_scoring)
        turn.reload
        expect(turn.score).to eq(16)
      end

      it do
        iteractor.send(:compleate_pending_scoring)
        turn.reload
        expect(turn.status).to eq('completed')
      end
    end

    context 'when :spare turn' do
      before do
        second_turn.update_column(:rolls_detail, { roll_type: :normal, shots: [pins_knocked_down] })
        turn.update_column(:rolls_detail, { roll_type: :spare, shots: [6, 4] })
        turn.pending_scoring!
      end

      it do
        iteractor.send(:compleate_pending_scoring)
        turn.reload
        expect(turn.score).to eq(13)
      end

      it do
        iteractor.send(:compleate_pending_scoring)
        turn.reload
        expect(turn.status).to eq('completed')
      end
    end
  end

  describe '#define_status_current_turn' do
    let(:turn_identifier) { turn.id }
    let(:pins_knocked_down) { 3 }

    context 'when :normal one shot' do
      before do
        turn.update_column(:rolls_detail, { roll_type: :normal, shots: [pins_knocked_down] })
      end

      it do
        iteractor.send(:define_status_current_turn)
        turn.reload
        expect(turn.status).to eq('playing')
      end
    end

    context 'when second :normal turn' do
      let(:second_turn) { Turn.create(player:, game:, status: :playing) }
      let(:turn_identifier) { second_turn.id }
      let(:pins_knocked_down) { 3 }

      before do
        second_turn.update_column(:rolls_detail, { roll_type: :normal, shots: [pins_knocked_down, pins_knocked_down] })
        turn.update_column(:rolls_detail, { roll_type: :normal, shots: [pins_knocked_down, pins_knocked_down] })
        turn.update_column(:score, pins_knocked_down + pins_knocked_down)
        turn.completed!
      end

      it do
        iteractor.send(:define_status_current_turn)
        second_turn.reload
        expect(second_turn.status).to eq('completed')
      end

      it do
        iteractor.send(:define_status_current_turn)
        second_turn.reload
        expect(second_turn.score).to eq(12)
      end
    end

    context 'when :spare turn' do
      before do
        turn.update_column(:rolls_detail, { roll_type: :spare, shots: [7, pins_knocked_down] })
      end

      it do
        iteractor.send(:define_status_current_turn)
        turn.reload
        expect(turn.status).to eq('pending_scoring')
      end

      it do
        iteractor.send(:define_status_current_turn)
        turn.reload
        expect(turn.score).to be_nil
      end
    end

    context 'when :strike turn' do
      before do
        turn.update_column(:rolls_detail, { roll_type: :spare, shots: [10] })
      end

      it do
        iteractor.send(:define_status_current_turn)
        turn.reload
        expect(turn.status).to eq('pending_scoring')
      end

      it do
        iteractor.send(:define_status_current_turn)
        turn.reload
        expect(turn.score).to be_nil
      end
    end
  end
end
