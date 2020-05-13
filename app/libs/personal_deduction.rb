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
    now = Date.today
    now.year - birthday.year - (now.strftime('%m%d') < birthday.strftime('%m%d') ? 1 : 0)
  end

  def korean_age
    Date.today.year - birthday.year + 1
  end

  def new_born?
    twentieth_century? && residence_number.start_with?((Date.today.year % 100).to_s)
  end

  def elder?
    age >= 70
  end

  def dependant?
    (20 >= age || age >= 60)
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
    amount += 1000000 if single_parent
    amount += 500000 if woman_deduction && !single_parent
    amount
  end
end