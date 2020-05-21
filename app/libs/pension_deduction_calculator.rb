module PensionDeductionCalculator
  def personal_pension_deduction
    amount = (personal_pension * 0.4).round(3).to_i
    amount > 720000 ? 720000 : amount
  end
end