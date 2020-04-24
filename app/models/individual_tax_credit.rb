class IndividualTaxCredit < ApplicationRecord
  has_many: individual_personal_deductions

  def online_declare_tax_code
    "244"
  end

  def online_declare_tax_credit_amount
  end

  def children_tax_credit_code
    "273"
  end

  def children_tax_credit_amount
    children_size = individual_personal_deductions.children.size
    return 150000 * children_size if children_size <= 2
    return 300000 + (300000 * children_size - 2)
  end

  def newborn_children_tax_code
    "290"
  end

  def newborn_baby_tax_credit_amount
    return individual_personal_deductions.newborn_babies.size * 300000 if individual_personal_deductions.children.size <= 1
    return individual_personal_deductions.newborn_babies.size * 500000 if individual_personal_deductions.children.size <= 2
    individual_personal_deductions.newborn_babies.size * 700000
  end
end
