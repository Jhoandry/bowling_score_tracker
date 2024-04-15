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

  describe 'normal turn definitions' do
    let(:rolls_detail) do
      {
        'roll_type' => 'normal',
        'shots' => shots
      }
    end

    context 'with both shots' do
      let(:shots) { [3, 6] }
      let(:current_score) { 4 }

      it 'cans completed' do
        expect(definitions).to be_normal_completed(rolls_detail)
      end

      it 'not pending_scoring' do
        expect(definitions).not_to be_must_pending_score(rolls_detail)
      end

      it 'expected score' do
        expect(definitions.normal_score(rolls_detail, current_score)).to eq(current_score + shots.sum)
      end
    end

    context 'with just one shot' do
      let(:shots) { [5] }

      it 'cans completed' do
        expect(definitions).not_to be_normal_completed(rolls_detail)
      end

      it 'not pending_scoring' do
        expect(definitions).not_to be_must_pending_score(rolls_detail)
      end
    end
  end

  describe 'spare turn definitions' do
    let(:rolls_detail) do
      {
        'roll_type' => 'spare',
        'shots' => [4, 6]
      }
    end

    let(:next_rolls_detail) do
      {
        'roll_type' => 'normal',
        'shots' => [5]
      }
    end

    let(:current_score) { 7 }
    let(:score_expected) { 22 }

    it 'cans completed' do
      expect(definitions).not_to be_normal_completed(rolls_detail)
    end

    it 'not pending_scoring' do
      expect(definitions).to be_must_pending_score(rolls_detail)
    end

    it 'can be score' do
      expect(definitions).to be_can_score_pending_turn(rolls_detail, next_rolls_detail)
    end

    it 'expected score' do
      expect(definitions.score_pending_turn(rolls_detail, next_rolls_detail, current_score)).to eq(score_expected)
    end
  end

  describe 'strike turn definitions' do
    let(:rolls_detail) do
      {
        'roll_type' => 'strike',
        'shots' => [10]
      }
    end

    let(:next_rolls_detail) do
      {
        'roll_type' => 'normal',
        'shots' => [4, 2]
      }
    end

    let(:current_score) { 7 }
    let(:score_expected) { 23 }

    it 'cans completed' do
      expect(definitions).not_to be_normal_completed(rolls_detail)
    end

    it 'not pending_scoring' do
      expect(definitions).to be_must_pending_score(rolls_detail)
    end

    context 'when next turn has enough data to scoring' do
      it 'can be score' do
        expect(definitions).to be_can_score_pending_turn(rolls_detail, next_rolls_detail)
      end

      it 'expected score' do
        expect(definitions.score_pending_turn(rolls_detail, next_rolls_detail, current_score)).to eq(score_expected)
      end
    end

    context 'when next turn does not have enough data to scoring' do
      let(:next_rolls_detail) do
        {
          'roll_type' => 'normal',
          'shots' => [4]
        }
      end

      it 'cannot be score' do
        expect(definitions).not_to be_can_score_pending_turn(rolls_detail, next_rolls_detail)
      end
    end
  end
end
