module FoodtaxHelper
  def tax_period_start_date(business: nil, date: Date.current)
    case business.taxation_type
    when "간이과세자"
      date.beginning_of_year
    when "법인사업자"
      date.beginning_of_quarter
    else
      return date.change(month: 1, day: 1) if date.month < 7
      date.change(month: 7, day: 1)
    end
  end

  def tax_period_end_date(business: nil, date: Date.current)
    case business.taxation_type
    when "간이과세자"
      date.end_of_year
    when "법인사업자"
      date.end_of_quarter
    else
      return date.change(month: 6, day: 30) if date.month < 7
      date.change(month: 12, day: 31)
    end
  end

  def foodtax_tax_type(business)
    if business.taxation_type == "간이과세자" then 2
    elsif business.taxation_type == "면세사업자" then 3
    else 1
    end
  end

  def tax_declare_year
    (Date.today.month == 1) ? Date.today.last_year.year : Date.today.year
  end

  def tax_declare_term
    (Date.today - 1.month <= 6) ? 1 : 2
  end

  def tax_declare_duration(business)
    date_of_declare_date = Date.today - 1.month
    if business.simple_taxpayer?
      date_of_declare_date.beginning_of_year..date_of_declare_date.end_of_year.end_of_day
    elsif business.incorporated?
      date_of_declare_date.beginning_of_quarter..date_of_declare_date.end_of_quarter.end_of_day
    elsif date_of_declare_date.month <= 6
      date_of_declare_date.beginning_of_year..Date.new(date_of_declare_date.year, 6, 30).end_of_day
    else
      Date.new(date_of_declare_date.year, 7, 1)..date_of_declare_date.end_of_quarter.end_of_day
    end
  end

  def tax_declare_start_date(year: tax_declare_year, term: tax_declare_term)
    (term == 1) ? "#{year}0101" : "#{year}0701"
  end

  def tax_declare_end_date(year: tax_declare_year, term: tax_declare_term)
    (term == 1) ? "#{year}0630" : "#{year}1231"
  end

  def tax_declare_due_date(year: tax_declare_year, term: tax_declare_term)
    (term == 1) ? "#{year}0131" : "#{year}1231"
  end
end
