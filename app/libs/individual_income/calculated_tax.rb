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

    def base_taxation
      @base_taxation ||= [0, total_income - income_deduction].max
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
      amount = base_taxation * tax_rate
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
      @calculated_tax ||= [0, amount.to_i].max
    end

    def determined_tax
      [calculated_tax - tax_credit - tax_exemption, 0].max 
    end

    def online_declare_credit_amount
      return 0 if calculated_tax <= 0
      online_declare_credit_amount = 20000
      base_amount = calculated_tax - online_declare_credit_amount
      minimum_tax = begin
        if calculated_tax <= 30000000
          (calculated_tax * 0.35).to_i
        else
          (10500000 + (calculated_tax - 30000000) * 0.45).to_i
        end
      end
      return online_declare_credit_amount if base_amount >= minimum_tax
      online_declare_credit_amount - [online_declare_credit_amount, minimum_tax - base_amount].min
    end

    def calculated_tax_with_penalty
      @calculated_tax_with_penalty ||= calculated_tax + penalty_tax
    end

    def limited_tax_credit
      [calculated_tax_with_penalty, tax_credit + online_declare_credit_amount].min
    end

    def limited_tax_exemption
      [calculated_tax_with_penalty - limited_tax_credit, tax_exemption].min
    end

    def payment_tax
      @payment_tax ||= [(calculated_tax_with_penalty - limited_tax_credit - limited_tax_exemption), 0].max - prepaid_tax
    end

    def calculated_local_tax
      [(calculated_tax * 0.1).round(3).to_i, 0].max
    end

    def penalty_local_tax
      0
    end

    def calculated_local_tax_with_penalty
      @calculated_local_tax_with_penalty ||= calculated_local_tax + penalty_local_tax
    end

    def limited_local_tax_credit
      [calculated_local_tax_with_penalty, ((tax_credit + online_declare_credit_amount) * 0.1).round(3).to_i].min
    end

    def limited_local_tax_exemption
      [(calculated_tax_with_penalty - limited_local_tax_credit), (tax_exemption * 0.1).round(3).to_i].min
    end

    def prepaid_local_tax
      0
    end

    def payment_local_tax
      @payment_local_tax ||= [(calculated_local_tax_with_penalty - limited_local_tax_credit - limited_local_tax_exemption), 0].max - prepaid_local_tax
    end

    def as_json
      {
        business_incomes: business_incomes,
        expenses: expenses,
        total_income: total_income,
        income_deduction: income_deduction,
        base_taxation: base_taxation,
        tax_rate: (tax_rate * 100).to_i,
        calculated_tax: calculated_tax,
        tax_exemption: limited_tax_exemption,
        tax_credit: limited_tax_credit,
        penalty_tax: penalty_tax,
        prepaid_tax: prepaid_tax,
        payment_tax: payment_tax,
        payment_local_tax: payment_local_tax,
      }.as_json
    end
  end
end
