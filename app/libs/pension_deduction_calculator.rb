module PensionDeductionCalculator
  def personal_pension_deduction
    amount = (personal_pension * 0.4).round(3).to_i
    amount > 720000 ? 720000 : amount
  end

  def merchant_pension_deduction
    if business_income_sum > 100000000
      return merchant_pension > 2000000 ? 2000000 : merchant_pension
    elsif business_income_sum > 40000000
      return merchant_pension > 3000000 ? 3000000 : merchant_pension
    else
      return merchant_pension > 5000000 ? 5000000 : merchant_pension
    end
  end
end