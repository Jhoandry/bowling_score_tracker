# Bowling Score Tracker API

This is a Ruby on Rails API designed to track and calculate the score of a bowling game.

Main Features:

- Start a new bowling game: the API provides a path to start a new bowling game.

- Enter the number of pins knocked down per throw: Players can submit the number of pins knocked down per throw during the game.

- Get current game score: The API provides a way to calculate and get the current game score, including the score for each frame and the total game score.

More details about the scoring [here](https://es.wikipedia.org/wiki/Bowling)

## Development Setup

To run the service locally, you will need:
Ruby version 3.2.2. you can manage your local ruby version with [RVM](https://rvm.io/) or [RBENV](https://github.com/rbenv/rbenv)

Postgres headers to compile pg gem
```bash
brew install postgresql
```

Run the following to start a web server
```bash
bundle install
bundle exec rails db:setup
bundle exec rake db:migrate
bundle exec rails s
```

## Request documentation

### Start a new bowling game

Endpoint: `/games`
HTTP Method: POST


Request Body (JSON):
```json
{
  "location": "Freeletics lane",
  "players": ["player 1", "player 2"]
}
```

- `location` (required): Represent the lane of the bowling game (type: string).
- `players` (required): A list of player names participating in the game (type: array of strings).

Responses:
- 200 OK: If the game is created successfully.

### Enter the number of pins knocked down per throw

Endpoint: `/turns`
HTTP Method: POST

Request Body (JSON):
```json
{
  "turn_id": 1,
  "pins_knocked_down": 10
}
```

- `turn_id` (required): The identifier of the active turn (type: integer).
- `pins_knocked_down` (required): The number of pins knocked down in the current throw (type: integer).

Responses:
- 200 OK: If the turn is recorded successfully.
- 422 Unprocessable Entity: If there is an error processing the request. Possible error scenarios include:
  - The game is already finalized.
  - The `pins_knocked_down` parameter is invalid.

### Get current game score

Endpoint: /games
HTTP Method: GET

Request Parameters:
- id (required): Unique ID of the game you want to retrieve.

Responses:
- 200 OK: Returns details of the requested game.
- 422 Unprocessable Entity: If the game does not exist

#### Response Example: (All the request have same response)
```json
{
  "id": 38, // Game Identifier
  "location": "Freeletics lane",
  "players": [
    {
      "name": "player 1",
      "turns": [
        {
          "identifier": 1, // with this identifier must do the "Enter the number of pins knocked down per throw"
          "shots": [], // pins knocked down in al shots
          "type": null, // normal, spare, strike
          "score": 0,
          "status": "playing" // Represent the current player
        }
      ],
      "total_score": 0
    }
  ]
}
```
