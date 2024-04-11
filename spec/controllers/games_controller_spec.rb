RSpec.describe GamesController do
  describe '#create' do
    subject(:create) { post :create, format: :json, params: body_request }

    context 'with all required data' do
      let(:body_request) do
        {
          location: 'Freeletics lane',
          players: ['player 1', 'player 2', 'player 3']
        }
      end

      let(:games) { Game.count }
      let(:players) { Player.count }

      it { is_expected.to have_http_status :ok }

      it 'creates a new game' do
        expect { create }.to change(Game, :count).by(1)
      end

      it 'creates new players' do
        expect { create }.to change(Player, :count).by(3)
      end
    end

    context 'without all required data start a new game' do
      let(:body_request) do
        {
          players: []
        }
      end

      it do
        expect { create }.to raise_error(ActionController::ParameterMissing,
                                         'param is missing or the value is empty: players')
      end
    end
  end
end
