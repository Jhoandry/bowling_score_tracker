RSpec.describe TurnDefinitions do
  let(:definitions) { Class.new { extend TurnDefinitions } }

  describe '#roll_type' do
    let(:roll_type) { definitions.roll_type(shots_count, total_pins_knocked_down) }

    context 'when :normal in two shots' do
      let(:shots_count) { 2 }
      let(:total_pins_knocked_down) { 7 }

      it do
        expect(roll_type).to eq(:normal)
      end
    end

    context 'when :spare' do
      let(:shots_count) { 2 }
      let(:total_pins_knocked_down) { 10 }

      it do
        expect(roll_type).to eq(:spare)
      end
    end

    context 'when :strike' do
      let(:shots_count) { 1 }
      let(:total_pins_knocked_down) { 10 }

      it do
        expect(roll_type).to eq(:strike)
      end
    end
  end

  describe '#build_roll_detail' do
    let(:roll_detail) { definitions.build_roll_detail(turn, pins_knocked_down).deep_symbolize_keys }
    let(:game) { Game.create }
    let(:player) { Player.create(name: 'test player name') }
    let!(:turn) { Turn.create(player:, game:) }
    let(:first_shot_roll_detail) do
      {
        roll_type: :normal,
        shots: [pins_knocked_down_first_shot]
      }
    end

    context 'when first normal shot' do
      let(:pins_knocked_down) { 7 }
      let(:expected_roll_details) do
        {
          roll_type: :normal,
          shots: [pins_knocked_down]
        }
      end

      it do
        expect(roll_detail).to include(expected_roll_details)
      end
    end

    context 'when second normal shot' do
      let(:pins_knocked_down) { 2 }
      let(:pins_knocked_down_first_shot) { 7 }
      let(:expected_roll_details) do
        {
          roll_type: :normal,
          shots: [pins_knocked_down_first_shot, pins_knocked_down]
        }
      end

      before do
        turn.update_column(:rolls_detail, first_shot_roll_detail)
      end

      it do
        expect(roll_detail).to include(expected_roll_details)
      end
    end

    context 'when spare turn' do
      let(:pins_knocked_down) { 5 }
      let(:pins_knocked_down_first_shot) { 5 }
      let(:expected_roll_details) do
        {
          roll_type: :spare,
          shots: [pins_knocked_down_first_shot, pins_knocked_down]
        }
      end

      before do
        turn.update_column(:rolls_detail, first_shot_roll_detail)
      end

      it do
        expect(roll_detail).to include(expected_roll_details)
      end
    end

    context 'when strike turn' do
      let(:pins_knocked_down) { 10 }
      let(:expected_roll_details) do
        {
          roll_type: :strike,
          shots: [pins_knocked_down]
        }
      end

      it do
        expect(roll_detail).to include(expected_roll_details)
      end
    end

    context 'when invalid pins_knocked_down' do
      let(:pins_knocked_down) { 11 }

      it do
        expect { roll_detail }.to raise_error(ArgumentError, 'Invalid number of pins knocked down')
      end
    end
  end
end
