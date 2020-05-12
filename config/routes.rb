Rails.application.routes.draw do
  get "auth/status", to: "auth#status"
  get "declare_users/:id/additional_deduction", to: "declare_users#additional_deduction"
  post "declare_users/:id/status", to: "declare_users#status"
  resources :declare_users, except: [:index]
  resources :deductible_persons do
    collection do
      get 'classifications'
    end
  end
  resources :business_expenses do
    collection do
      get 'classifications'
      get 'personal_cards'
    end
  end
  resources :simplified_bookkeepings do
    collection do
      get 'classifications'
      get 'purchase_type'
      get 'card_purchases_approvals'
    end
  end
  resources :classifications do
    collection do
      get 'relations'
      get 'business_expenses'
      get 'account_classifications'
      get 'banks'
    end
  end
  get "calculated_taxes", to: "calculated_taxes#index"
  get "calculated_taxes/deductions", to: "calculated_taxes#deductions"
  get "calculated_taxes/tax_credits", to: "calculated_taxes#tax_credits"
  get "calculated_taxes/tax_exemptions", to: "calculated_taxes#tax_exemptions"
  get "calculated_taxes/penalty_taxes", to: "calculated_taxes#penalty_taxes"
  get "hometax_business_incomes", to: "hometax_business_incomes#index"
  get "hometax_business_incomes/incomes", to: "hometax_business_incomes#incomes"
  post "hometax/scraped_callback", to: "hometax#scraped_callback"
end
