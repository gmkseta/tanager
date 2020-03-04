Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/", to: "users#login_for_cashnote"
  get "forum", to: "posts#index"

  get "signup", to: "users#login_for_cashnote"
  resources :users, only: [:new, :show, :edit, :create, :update]

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  get "logout", to: "sessions#destroy"
  get "login_cashnote", to: "users#login_cashnote"

  get "/posts/mine", to: "posts#mine"
  get "/posts/participating", to: "posts#participating"
  resources :posts do
    resources :comments
  end
  get "categories/:id", to: "categories#index"
  resources :categories, only: [:show]

  post "cashnotes/login", to: "cashnotes#login"
end
