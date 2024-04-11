RSpec.describe GamesController do
  describe '#create' do
    subject(:create) { post :create, format: :json, params: body_request }

    let(:body_request) do
      {
        location: 'Freeletics lane',
        players: ['player 1', 'player 2', 'player 3']
      }
    end

    it do
      expect(subject).to have_http_status :ok
    end
  end
end
