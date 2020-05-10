module IndividualIncome
  class CalculatedTax
    extend Dry::Initializer
    option :business_incomes
    option :expenses
    option :income_deduction
    option :tax_exemption
    option :tax_credit
    option :penalty_tax
    option :prepaid_tax

    def total_income
      @total_income ||= [business_incomes - expenses, 0].max
    end

    def limited_income_deduction
      [0, total_income - income_deduction].max
    end

    def base_taxation
      @base_taxation ||= limited_income_deduction
    end

    def tax_rate
      @tax_rate ||= if base_taxation < 12000000
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

    def calculated_tax
      @calculated_tax =amount = base_taxation * tax_rate
      case tax_rate
      when 0.15
        amount -= 1080000
      when 0.24
        amount -= 5220000
      when 0.35
        amount -= 14900000
      when 0.38
        amount -= 19400000
      when 0.40
        amount -= 25400000
      when 0.42
        amount -= 35400000
      end
      [0, amount.to_i].max
    end

    def calculated_tax_with_penalty
      @calculated_tax_with_penalty ||= calculated_tax + penalty_tax
    end

    def limited_tax_credit
      [calculated_tax_with_penalty, tax_credit].min
    end

    def limited_tax_exemption
      [calculated_tax_with_penalty - limited_tax_credit, tax_exemption].min
    end

    def payment_tax
      @payment_tax ||= [calculated_tax_with_penalty - limited_tax_credit - limited_tax_exemption, 0].max - prepaid_tax
    end

    def as_json
      {
        business_incomes: business_incomes,
        expenses: expenses,
        total_income: total_income,
        income_deduction: limited_income_deduction,
        base_taxation: base_taxation,
        tax_rate: (tax_rate * 100).to_i,
        calculated_tax: calculated_tax,
        tax_exemption: limited_tax_exemption,
        tax_credit: limited_tax_credit,
        penalty_tax: penalty_tax,
        prepaid_tax: prepaid_tax,
        payment_tax: payment_tax,
      }.as_json
    end
  end
end
