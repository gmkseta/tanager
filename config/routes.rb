Rails.application.routes.draw do
  get "auth/status", to: "auth#status"
  delete "auth/status", to: "auth#destroy" if Rails.env.development?

  resources :declare_users, only: [:show, :create, :update, :destroy]
  resources :deductable_persons
  get "classifications/relations", to: "classifications#relations"
end
