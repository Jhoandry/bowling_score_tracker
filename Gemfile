source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.3'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.8'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Config helps you easily manage environment specific settings in an easy and usable manner.
gem 'config'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  # testing framework
  gem 'rspec-rails'

  # An IRB alternative and runtime developer console
  gem 'pry'

  # Adds step-by-step debugging and stack navigation capabilities to pry using byebug.
  gem 'pry-byebug'

  # Automatic Ruby code style checking tool
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'annotate'
  gem 'web-console'
end

group :test do
  gem 'database_cleaner'
  # Library for stubbing and setting expectations on HTTP requests in Ruby
  gem 'webmock'
end
