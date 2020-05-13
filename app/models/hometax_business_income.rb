class HometaxBusinessIncome < ApplicationRecord
  belongs_to :hometax_individual_income
  scope :co_founders, ->{ where(business_type: "단독") }
  scope :freelancers, ->{ where(registration_number: [nil, '']) }

  def expense_by_base_ratio
    (income_amount * base_ratio_self * 0.01).to_i
  end

  def expense_by_simple_ratio
    (income_amount * simple_ratio_self * 0.01).to_i
  end
end
