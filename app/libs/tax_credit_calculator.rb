module TaxCreditCalculator
  def children_tax_credit_amount
    return 150000 * children_size if children_size <= 2
    return 300000 + (300000 * children_size - 2)
  end

  def newborn_baby_tax_credit_amount
    return newborn_baby_size * 300000 if children_size <= 1
    return newborn_baby_size * 500000 if children_size <= 2
  end
end