class IndividualPersonalDeduction < ApplicationRecord
  # enum relation_code: { "me", "ascendants", "ascendants_of_spouse", "spouse", "children", "other_lineal_descendant", "siblings", "basic_livelihood", "foster_children"}

  def age
    birthdate = (residence_number[6].eql?("3") || residence_number[6].eql?("4")) ? "20" : "19"
    birthday = Date.parse("#{birthdate}#{residence_number[0..5]}")
    age = Date.today.year - birthday.year
    age -= 1 if Date.today < birthday + age.years
    age
  end

  def local?
    (residence_number[6] == "5" || residence_number(6) == "6")
  end

  def elder?
    age >= 70
  end

  def me_and_spouse?
    relation_code.eql?("0") || relation_code.eql?("3")
  end

  def dependant?
    (20 >= age || age >= 60) && !me_and_spouse?
  end

  def child?
    age <= 6
  end 

  def deduct_amount
    amount = 0
    amount += 1500000 if me_and_spouse?
    amount += 1500000 if dependant?
    amount += 2000000 if disalbed
    amount += 1000000 if single_parent
    amount += 500000 if woman_deduction && !single_parent
    amount
  end

  def relation_code_to_income_deduction_code
    return "F01" if relation_code.eql?("0")
    return "F02" if relation_code.eql?("3")
    return "F03" if dependant
    return "F05" if elder
    return "F06" if disalbed
    return "F07" if disalbed
    return "F14" if disalbed
  end

  def to_income_deduction
    i = IndividualIncomeDeduction.new(
    )
  end
end