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

      it do
        expect(create).to have_http_status(:ok)
      end

      it 'is expected to creates a new game' do
        expect { create }.to change(Game, :count).by(1)
      end

      it 'is expected to creates new players' do
        expect { create }.to change(Player, :count).by(3)
      end

      it 'is expected to initialize new turn by player' do
        expect { create }.to change(Turn, :count).by(3)
      end
    end

    context 'without all required data start a new game' do
      let(:body_request) do
        {
          players: []
        }
      end

      it do
        expect(create).to have_http_status(:unprocessable_entity)
      end

      it 'is expected to respond with error message' do
        create
        expect(response.body).to include('param is missing or the value is empty: players')
      end
    end
  end
end
