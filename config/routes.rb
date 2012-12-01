Plinq::Application.routes.draw do
  devise_for :users

  resources :songs, :authentications

  # for omniauth authentications with other providers
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

  get "/music" => "pages#music", :as => "music"

  root :to => 'songs#index'
end
