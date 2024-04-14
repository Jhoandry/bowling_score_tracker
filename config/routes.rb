Rails.application.routes.draw do
  resources :games, only: %i[create index]
  resources :turns, only: %i[create]
end
