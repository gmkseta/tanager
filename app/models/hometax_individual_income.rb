class HometaxIndividualIncome < ApplicationRecord
  belongs_to :declare_user
  has_many :hometax_business_incomes
  include PensionDeductionCalculator
  PENALTY_METHODS = %w{unfaithful_business_report_amount not_issued_cash_receipts_penalty unfaithful_business_report_penalty decline_cash_receipts_penalty decline_card_penalty}

  def business_income_sum
    hometax_business_incomes.sum(&:income_amount)
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

  def expenses_sum_by_ratio
    return hometax_business_incomes.sum(&:expense_by_base_ratio) if base_expense_rate.eql?("기준경비율")
    hometax_business_incomes.sum(&:expense_by_simple_ratio)
  end

  def expenses_ratio
    return hometax_business_incomes.first.base_ratio_self if base_expense_rate.eql?("기준경비율")
    hometax_business_incomes.first.simple_ratio_self
  end
end
