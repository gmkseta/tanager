module TaxCreditCalculator
  def children_tax_credit_amount
    return 150000 * children_size if children_size <= 2
    return 300000 + (300000 * children_size - 2)
  end

  def newborn_baby_tax_credit_amount
    return newborn_baby_size * 300000 if children_size <= 1
    return newborn_baby_size * 500000 if children_size <= 2
  end

  def pension_account_tax_credit_limit
    @pension_account_tax_credit_limit ||= total_income_amount > 100000000 ? 3000000 : 4000000
  end

  def pension_tax_rate
    @pension_tax_rate ||= total_income_amount <= 40000000 ? 0.15 : 0.12
  end

  def pension_account_tax_credit_amount
    ([hometax_individual_income.pension_account_tax_credit, pension_account_tax_credit_limit].min * pension_tax_rate).to_i
  end

  def retirement_pension_tax_credit_amount
    limit_amount = [7000000 - pension_account_tax_credit_limit, hometax_individual_income.retirement_pension_tax_credit].min
    (pension_account = limit_amount * pension_tax_rate).to_i
  end
end