class DeclareUser < ApplicationRecord
  extend AttrEncrypted
  include PersonalDeduction
  include TaxCreditCalculator

  enum status: %i(empty user deductible_persons business_expenses confirm payment done)
  STATUS_WORDS = %w(캐시노트로부터진입 유저생성 인적공제 경비확인 신고확인 결제요청 끝!)
  EXCEPT_JSON_FIELD = %i(user_id encrypted_residence_number encrypted_residence_number_iv hometax_account)
  CREDIT_METHODS = %i(base_tax_credit_amount online_declare_credit_amount children_tax_credit_amount newborn_baby_tax_credit_amount pension_account_tax_credit_amount retirement_pension_tax_credit_amount)

  belongs_to :user
  has_many :businesses, through: :user
  has_many :deductible_persons, dependent: :destroy
  has_many :business_expenses, dependent: :destroy
  has_many :simplified_bookkeepings, dependent: :destroy
  has_many :user_account_classification_rules, dependent: :destroy

  has_one :hometax_individual_income, dependent: :destroy
  has_many :hometax_business_incomes, through: :hometax_individual_income, dependent: :destroy
  has_many :hometax_social_insurances, dependent: :destroy

  scope :individual_incomes, ->{ where(declare_type: "income") }

  validate :valid_residence_number?
  validates :residence_number, presence: true, format: { with: /\A\d{13}\z/ }
  validates :declare_tax_type, presence: true
  validates :name, presence: true
  validates :address, presence: true
  validates :bank_account_number, format: { with: /\A\d{6,16}\z/ }, allow_nil: true
  validates :bank_code, inclusion: { in: Classification.banks.map { |b| b.slug }, message: :wrong_code }, allow_nil: true

  attr_encrypted :residence_number,
                 key: :encryption_key,
                 encode: true,
                 encode_iv: true,
                 encode_salt: true

  def encryption_key
    Rails.application.credentials.attr_encrypted[:encryption_key]
  end

  def status_word
    STATUS_WORDS[self.class.statuses[status]]
  end

  def hometax_address
    user.hometax_address
  end

  def deduction_amount
    1500000 + additional_deduction_amount
  end

  def single_parent?
    return false if (single_parent == false)
    (single_parent == true || single_parent.nil?) && applicable_single_parent?
  end

  def woman_deduction?
    return false if single_parent? || (woman_deduction == false) || (total_income_amount > 30000000)
    (woman_deduction == true || woman_deduction.nil?) && (applicable_woman_deduction_with_husband? || applicable_woman_deduction_without_husband?)
  end

  def applicable_single_parent?
    !married && deductible_persons.has_dependant_children?
  end

  def applicable_woman_deduction_with_husband?
    female? && married && total_income_amount <= 30000000
  end

  def applicable_woman_deduction_without_husband?
    female? && !married && deductible_persons.has_dependant? && total_income_amount <= 30000000
  end

  def deductible_persons_sum
    deductible_persons.sum(&:deduction_amount) + deduction_amount
  end

  def business_expenses_sum
    business_expenses.sum(&:amount)
  end

  def simplified_bookkeepings_sum
    simplified_bookkeepings.deductibles.sum(&:amount)
  end

  def pensions_sum
    hometax_individual_income.national_pension +
      hometax_individual_income.merchant_pension_deduction +
      hometax_individual_income.personal_pension_deduction
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

  def children_or_adopted_count
    deductible_persons.select { |p| [2, 8].any? p.classification_id }.length
  end

  def deductible_children_size
    deductible_persons.select { |p| (p.age >= 7 && p.age <= 20) || p.disabled }.length
  end

  def base_tax_credit_amount
    hometax_individual_income&.has_wage_income? ? 130000 : 70000
  end

  def online_declare_credit_amount
    if apply_bookkeeping?
      @calculated_tax_by_bookkeeping.online_declare_credit_amount
    else
      @calculated_tax_by_ratio.online_declare_credit_amount
    end
  end

  def tax_credit_amount
    base_tax_credit_amount +
      children_tax_credit_amount +
      newborn_baby_tax_credit_amount +
      pension_account_tax_credit_amount +
      retirement_pension_tax_credit_amount
  end

  def tax_exemption_amount
    0
  end

  def penalty_tax_sum
    hometax_individual_income.penalty_tax_sum
  end

  def prepaid_tax_sum
    hometax_individual_income.prepaid_tax
  end

  def calculated_tax_by_bookkeeping
    @calculated_tax_by_bookkeeping ||= IndividualIncome::CalculatedTax.new(
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
    @calculated_tax_by_ratio ||= IndividualIncome::CalculatedTax.new(
      business_incomes: business_incomes_sum,
      expenses: hometax_individual_income.expenses_sum_by_ratio,
      income_deduction: income_deduction,
      tax_exemption: tax_exemption_amount,
      tax_credit: tax_credit_amount,
      penalty_tax: penalty_tax_sum,
      prepaid_tax: prepaid_tax_sum,
    )
  end

  def apply_bookkeeping?
    calculated_tax_by_bookkeeping.payment_tax < calculated_tax_by_ratio.payment_tax
  end

  def calculated_tax
    return calculated_tax_by_bookkeeping if apply_bookkeeping?
    calculated_tax_by_ratio
  end

  def snowdon_businesses
    public_ids = businesses.map { |b| b.public_id }
    Snowdon::Business.where(public_id: public_ids)
  end

  def wage_sum
    snowdon_businesses.sum(&:wage)
  end

  def registerd_card_this_year?
    snowdon_businesses.map { |b| b.registerd_card_this_year? }.any?
  end

  def opened_at_this_year?
    user.businesses.map{ |b| 1.year.ago.all_year === b.opened_at }.any?
  end

  def total_deduction_amount
    deductible_persons.sum(&:deduction_amount) + deduction_amount + pensions_sum
  end

  def person_cd
    "P#{"%06d" % id}"
  end
end
