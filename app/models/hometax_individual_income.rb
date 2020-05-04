class HometaxIndividualIncome < ApplicationRecord
  belongs_to :declare_user
  has_many :hometax_business_incomes
end
