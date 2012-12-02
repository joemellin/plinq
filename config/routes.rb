Plinq::Application.routes.draw do
  devise_for :users

  resources :songs do
    member do
      match 'share'
    end
  end

  resources :authentications
  resources :leaderboard, :only => [:index]

  resources :users, :only => [:show]

  # for omniauth authentications with other providers
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

  get "/music" => "pages#music", :as => "music"

   # Easy routes for auth/account stuff
  as :user do
    get '/sign_in' => "devise/sessions#new"
    get '/login' => "devise/sessions#new"
    get '/sign_up' => "registrations#new"
    match '/logout' => "devise/sessions#destroy"
  end

  root :to => 'play#index'
end
