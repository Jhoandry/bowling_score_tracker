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
bundle exec rails s
```