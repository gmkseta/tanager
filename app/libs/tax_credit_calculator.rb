module TaxCreditCalculator
  def children_tax_credit_amount
    return 150000 * children_size if children_size <= 2
    return 300000 + (300000 * children_size - 2)
  end

  def newborn_baby_tax_credit_amount
    return newborn_baby_size * 300000 if children_size <= 1
    return newborn_baby_size * 500000 if children_size <= 2
  end

  def pensions_tax_credit_amount
    pension_account = [hometax_individual_income.pension_account_tax_credit, 4000000].min
    [(total_income_amount > 100000000 ? 3000000 : 4000000), hometax_individual_income.pension_account_tax_credit].min
    ([pension_account + hometax_individual_income.retirement_pension_tax_credit, 7000000].min * 0.12).to_i
  end
end