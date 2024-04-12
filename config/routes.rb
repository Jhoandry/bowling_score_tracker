Rails.application.routes.draw do
  resources :games, only: %i[create index]
end
