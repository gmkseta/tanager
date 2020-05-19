module TaxCreditCalculator
  def children_tax_credit_amount
    return 150000 * deductible_children_size if deductible_children_size <= 2
    300000 + (300000 * (deductible_children_size - 2))
  end

  def newborn_baby_tax_credit_amount
    return 0 if new_born_children_or_adopted_count <= 0
    base_born_order = children_or_adopted_count - new_born_children_or_adopted_count
    amount = new_born_children_or_adopted_count
      .times.each_with_index
      .map { |child, index| newborn_credit_amount(base_born_order + index) }.sum
  end

  def newborn_credit_amount(born_order)
    return 300000 if born_order <= 0
    return 500000 if born_order <= 1
    return 700000
  end

  def pension_account_tax_credit_limit
    @pension_account_tax_credit_limit ||= total_income_amount > 100000000 ? 3000000 : 4000000
  end

  def pension_tax_rate
    @pension_tax_rate ||= total_income_amount <= 40000000 ? 0.15 : 0.12
  end

  def pension_account_tax_credit_amount
    ([hometax_individual_income.pension_account_tax_credit, pension_account_tax_credit_limit].min * pension_tax_rate).round(3).to_i
  end

  def retirement_pension_tax_credit_amount
    limit_amount = [7000000 - pension_account_tax_credit_limit, hometax_individual_income.retirement_pension_tax_credit].min
    (limit_amount * pension_tax_rate).round(3).to_i
  end
end