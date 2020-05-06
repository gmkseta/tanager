class DeclareUser < ApplicationRecord
  extend AttrEncrypted
  include PersonalDeduction
  include TaxCreditCalculator

  enum status: %i(empty user deductible_persons business_expenses confirm done)
  JSON_FIELD = %i(id name residence_number address phone_number status)

  belongs_to :user
  has_many :deductible_persons, dependent: :destroy
  has_many :business_expenses, dependent: :destroy
  has_many :simplified_bookkeepings, dependent: :destroy
  has_many :user_account_classification_rules, dependent: :destroy

  has_one :hometax_individual_income, dependent: :destroy
  has_many :hometax_business_incomes, through: :hometax_individual_income, dependent: :destroy

  scope :individual_incomes, ->{ where(declare_type: "income") }

  validate :valid_residence_number?
  validates :residence_number, presence: true, length: { is: 13 }
  validates :declare_tax_type, presence: true
  validates :name, presence: true
  validates :address, presence: true
  
  attr_encrypted :residence_number,
                 key: :encryption_key,
                 encode: true,
                 encode_iv: true,
                 encode_salt: true

  def encryption_key
    Rails.application.credentials.attr_encrypted[:encryption_key]
  end

  def deduction_amount
    amount = default_amount + 1500000
    amount -= 1500000 if dependant?
    amount
  end

  def applicable_single_parent?
    !deductible_persons.has_spouse? && deductible_persons.has_dependant_children?
  end

  def applicable_woman_deduction?
    female? && !deductible_persons.has_spouse? && deductible_persons.has_dependant?
  end

  def deductible_persons_sum
    deductible_persons.sum(&:deduction_amount) + deduction_amount
  end

  def business_expenses_sum
    business_expenses.sum(&:amount)
  end

  def simplified_bookkeepings_sum
    simplified_bookkeepings.where(deductible: [true, nil]).sum(&:amount)
  end

  def pensions_sum
    hometax_individual_income.national_pension + hometax_individual_income.merchant_pension_deduction + hometax_individual_income.personal_pension_deduction
  end

  def business_incomes_sum
    hometax_individual_income.business_income_sum
  end

  def simplified_bookkeeping_base_expenses
    simplified_bookkeepings_sum + business_expenses_sum
  end

  def expenses_sum
    [simplified_bookkeeping_base_expenses, hometax_individual_income.expenses_sum_by_ratio].max
  end

  def total_income_amount
    business_incomes_sum - expenses_sum
  end

  def income_deduction
    deductible_persons_sum + pensions_sum
  end

  def children_size
    deductible_persons.select { |p| p.korean_age >= 7 && p.korean_age <= 20 }.length
  end

  def newborn_baby_size
    deductible_persons.select { |p| p.new_born? }.length
  end

  def base_tax_exemption
    hometax_individual_income.has_wage_income? ? 130000 : 70000
  end

  def tax_exemption_amount
    base_tax_exemption
  end

  def tax_credit_amount
    children_tax_credit_amount + newborn_baby_tax_credit_amount
  end

  def penalty_tax_sum
    hometax_individual_income.penalty_tax_sum
  end

  def prepaid_tax_sum
    hometax_individual_income.prepaid_tax
  end

  def calculated_tax_by_bookkeeping
    IndividualIncome::CalculatedTax.new(
      business_incomes: business_incomes_sum,
      expenses: simplified_bookkeeping_base_expenses,
      income_deduction: income_deduction,
      tax_exemption: tax_exemption_amount,
      tax_credit: tax_credit_amount,
      penalty_tax: penalty_tax_sum,
      prepaid_tax: prepaid_tax_sum,
    )
  end
    
  def calculated_tax_by_ratio
    IndividualIncome::CalculatedTax.new(
      business_incomes: business_incomes_sum,
      expenses: hometax_individual_income.expenses_sum_by_ratio,
      income_deduction: income_deduction,
      tax_exemption: tax_exemption_amount,
      tax_credit: tax_credit_amount,
      penalty_tax: penalty_tax_sum,
      prepaid_tax: prepaid_tax_sum,
    )
  end
end
