class HometaxIndividualIncome < ApplicationRecord
  belongs_to :declare_user
  has_many :hometax_business_incomes
  include PensionDeductionCalculator

  PENALTY_METHODS = %w{unfaithful_business_report_amount not_issued_cash_receipts_penalty unfaithful_business_report_penalty decline_cash_receipts_penalty decline_card_penalty}

  def business_income_sum
    hometax_business_incomes.sum(&:income_amount)
  end

  def declarable?
    is_simplified_bookkeeping? && !(has_other_incomes?) && !(has_penalty_tax?) && !(has_multiple_businesses?) && !(has_freelancer_income?) && !(has_co_founder?) && !(real_estate_rental?)
  end

  def is_simplified_bookkeeping?
    account_type.eql?("간편장부대상자")
  end

  def has_other_incomes?
    interest_income || dividend_income || wage_single_income || wage_multiple_income || pension_income || other_income || religions_income
  end

  def has_penalty_tax?
    penalty_tax_sum > 0 || not_register_cash_receipts.present? || no_business_account_penalty.present?
  end

  def has_multiple_businesses?
    business_income_by_registration_number.length > 1
  end

  def has_freelancer_income?
    hometax_business_incomes.freelancers.length > 0
  end

  def has_co_founder?
    hometax_business_incomes.co_founders.length > 0
  end

  def real_estate_rental?
    return true if declare_type.include?("주택임대소득")
    hometax_business_incomes.map { |b| %{701101 701102 701103 701104 701301}.include?(b.classficaition_code) }.any?
  end

  def has_wage_income?
    wage_single_income && wage_multiple_income
  end

  def business_income_by_registration_number
    hometax_business_incomes.group_by(&:registration_number)
  end

  def penalty_tax_sum
    (unfaithful_report_invoice_penalty +
      not_issued_cash_receipts_penalty +
      decline_cash_receipts_penalty +
      decline_card_penalty +
      unfaithful_business_report_penalty).to_i
  end

  def unfaithful_report_invoice_penalty
    (unfaithful_report_invoice_amount * 0.01).to_i
  end

  def not_issued_cash_receipts_penalty
    (not_issued_cash_receipts_amount * 0.2).to_i
  end

  def unfaithful_business_report_penalty
    (unfaithful_business_report_amount * 0.005).to_i
  end

  def decline_cash_receipts_penalty
    (decline_cash_receipts_amount * 0.05 + decline_cash_receipts_count * 5000).to_i
  end

  def decline_card_penalty
    (decline_cards_amount * 0.05 + decline_cards_count * 5000).to_i
  end

  def is_simple_ratio?
    base_expense_rate.eql?("단순경비율")
  end

  def base_ratio_self
    hometax_business_incomes.first.base_ratio_self
  end

  def base_ratio_basic
    hometax_business_incomes.first.base_ratio_basic
  end

  def simple_ratio_self
    hometax_business_incomes.first.simple_ratio_self
  end

  def simple_ratio_basic
    hometax_business_incomes.first.simple_ratio_basic
  end

  def expenses_sum_by_base_ratio
    hometax_business_incomes.sum(&:expense_by_base_ratio)
  end

  def expenses_sum_by_simple_ratio
    hometax_business_incomes.sum(&:expense_by_simple_ratio)
  end

  def expenses_sum_by_ratio
    return expenses_sum_by_simple_ratio if is_simple_ratio?
    expenses_sum_by_base_ratio
  end

  def expenses_ratio
    return simple_ratio_basic if is_simple_ratio?
    base_ratio_basic
  end
end
