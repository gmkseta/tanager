Rails.application.routes.draw do
  get "auth/status", to: "auth#status"
  resources :declare_users, only: [:create, :update, :destroy]
  resources :deductable_persons
end
