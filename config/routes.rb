Plinq::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => 'registrations'}

  resources :songs do
    member do
      match 'share'
      post 'played'
      post 'listened'
    end
  end

  resources :authentications
  resources :leaderboard, :only => [:index]

  resources :users, :only => [:show, :edit, :update]

  # for omniauth authentications with other providers
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failure'

  get "/music" => "pages#music", :as => "music"

  match '/capture_and_login' => 'application#capture_and_login', :as => :capture_and_login

   # Easy routes for auth/account stuff
  as :user do
    get '/sign_in' => "devise/sessions#new"
    get '/login' => "devise/sessions#new"
    get '/sign_up' => "registrations#new"
    match '/logout' => "devise/sessions#destroy"
  end

  root :to => 'play#index'
end
