Rails.application.routes.draw do
  get "auth/status", to: "auth#status"
  get "declare_users/:id/additional_deduction", to: "declare_users#additional_deduction"
  resources :declare_users, except: [:index]
  resources :deductible_persons do
    collection do
      get 'classifications'
      post 'confirm'
    end
  end
  resources :business_expenses do
    collection do
      get 'classifications'
      post 'confirm'
    end
  end
  resources :simplified_bookkeepings do
    collection do
      get 'classifications'
      post 'confirm'
      get 'purchase_type'
      get 'card_purchases_approvals'
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
