module PersonalDeduction
  def valid_residence_number?
    unless (birthday.present? rescue false) && birthday <= Date.today
      errors.add(:residence_number, :invalid)
    end
  end

  def is_local?
    %w{0 1 2 3 4 9}.any?(residence_number[6])
  end

  def birthday
    ((twentieth_century? ? "20" : "19") + residence_number[0..5]).to_date
  end

  def twentieth_century?
     %w{3 4 7 8}.any?(residence_number[6])
  end

  def female?
    residence_number[6].to_i.even?
  end

  def age
    Date.today.last_year.year - birthday.year
  end

  def new_born?
    Date.today.last_year.beginning_of_year <= birthday
  end

  def elder?
    age >= 70
  end

  def dependant?
    (20 >= age || age >= 60) || disabled
  end

  def default_deduction_amount
    amount = 0
    amount += 1500000 if spouse?
    amount += 1500000 if dependant? && !spouse?
    amount
  end

  def additional_deduction_amount
    amount = 0
    amount += 2000000 if disabled
    amount += 1000000 if elder?
    amount += 1000000 if single_parent?
    amount += 500000 if woman_deduction? && !single_parent?
    amount
  end
end