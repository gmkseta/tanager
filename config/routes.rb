Rails.application.routes.draw do
  get "auth/status", to: "auth#status"
  delete "auth/status", to: "auth#destroy" if Rails.env.development?

  resources :declare_users, except: [:index]
  resources :deductible_persons, :business_expenses do
    collection do
      get 'classifications'
      post 'confirm'
    end
  end

  resources :classifications do
    collection do
      get 'relations'
      get 'business_expenses'
      get 'account_classifications'
    end
  end
end
