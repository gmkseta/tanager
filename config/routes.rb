require "sidekiq/web"

Rails.application.routes.draw do
  get "/", to: proc { [200, {}, ['']] }
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
      get 'hometax_card_purchases'
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
  get "calculated_taxes/declared", to: "calculated_taxes#declared"
  get "calculated_taxes/deductions", to: "calculated_taxes#deductions"
  get "calculated_taxes/tax_credits", to: "calculated_taxes#tax_credits"
  get "calculated_taxes/tax_exemptions", to: "calculated_taxes#tax_exemptions"
  get "calculated_taxes/penalty_taxes", to: "calculated_taxes#penalty_taxes"
  get "hometax_business_incomes", to: "hometax_business_incomes#index"
  get "hometax_business_incomes/incomes", to: "hometax_business_incomes#incomes"
  post "hometax/scraped_callback", to: "hometax#scraped_callback"
  get "estimated_income_taxes", to: "estimated_income_taxes#index"
  resources :vat_return_files, only: [:create]

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest("kcd")) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest("123abc!@#"))
  end

  mount Sidekiq::Web => "/sidekiq"
end
