module PersonalDeduction
  def valid_residence_number?
    unless (birthday.present? rescue false) && birthday <= Date.today
      errors.add(:residence_number, "Invalid date format")
    end
  end

  def is_local?
    %w{0 1 2 3 4 9}.any?(residence_number[6])
  end

  def birthday
    (twentieth_century? ? "20" : "19" + residence_number[0..5]).to_date
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

  def elder?
    age >= 70
  end

  def dependant?
    (20 >= age || age >= 60)
  end

  def default_amount
    amount = 0
    amount += 1500000 if dependant?
    amount += 2000000 if disabled
    amount += 1000000 if elder?
    amount += 1000000 if single_parent
    amount += 500000 if woman_deduction && !single_parent
    amount
  end
end