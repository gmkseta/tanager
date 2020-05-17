class HometaxBusinessIncome < ApplicationRecord
  belongs_to :hometax_individual_income
  scope :co_founders, ->{ where(business_type: "공동") }
  scope :freelancers, ->{ where(registration_number: [nil, '']) }

  RATIO_FOR_BASE_EXPENSE=2.6
  RATIO_FOR_SIMPLE_EXPENSE=3.2

  def expense_by_base_ratio
    default_expense_by_base_ratio = (income_amount * (base_ratio_self * 0.01).round(3)).to_i
    calculated_expnese_base_ratio = if is_simplified_bookkeeping?
      [(expense_by_simple_ratio * RATIO_FOR_BASE_EXPENSE).to_i, default_expense_by_base_ratio].max
    else
      [(expense_by_simple_ratio * RATIO_FOR_SIMPLE_EXPENSE).to_i, default_expense_by_base_ratio].max
    end
    calculated_expnese_base_ratio
  end

  def expense_by_simple_ratio
    (income_amount * (simple_ratio_self * 0.01).round(3)).to_i
  end

  def is_simplified_bookkeeping?
    account_type.eql?("간편장부")
  end
end
