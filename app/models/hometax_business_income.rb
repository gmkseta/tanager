class HometaxBusinessIncome < ApplicationRecord
  belongs_to :hometax_individual_income

  def expense_by_base_ratio
    (income_amount * base_ratio_self * 0.01).to_i
  end

  def expense_by_simple_ratio
    (income_amount * simple_ratio_self * 0.01).to_i
  end
end
