module IndividualIncome
  class IncomeDeduction
    def tax_rate(base_taxation)
      if base_taxation < 12000000
        0.06
      elsif base_taxation < 46000000
        0.15
      elsif base_taxation < 88000000
        0.24
      elsif base_taxation < 150000000
        0.35
      elsif base_taxation < 300000000
        0.38
      elsif base_taxation < 500000000
        0.40
      else
        0.42
      end
    end

    def calculated_amount(base_taxation)
      amount = base_taxation * tax_rate
      case tax_rate
      when 0.15
        amount - 1080000
      when 0.24
        amount - 5220000
      when 0.35
        amount - 14900000
      when 0.38
        amount - 19400000
      when 0.40
        amount - 25400000
      when 0.42
        amount - 35400000
      end
    end

    def personal_pension(payment)
      amount = payment * 0.4
      amount > 720000 ? 720000 : amount
    end

    def merchant_pension(payment, business_income)
      if business_income > 100000000
        payment > 2000000 ? 2000000 : payment
      elsif business_income > 40000000
        payment > 3000000 ? 3000000 : payment
      else
        payment > 5000000 ? 5000000 : payment
      end
    end
  end
end
