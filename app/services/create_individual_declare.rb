class CreateIndividualDeclare < Service::Base
  option :declare_user_id

  def run
    individual_declare = IndividualDeclare.create(
      declare_user_id: declare_user_id,
      declare_code: "01",
      individual: true,
      civil_appeal_code: "FA001",
      declare_date: Date.today.last_year.beginning_of_year,
      submit_at: Date.today,
      declare_start_date: "#{Date.today.year}0101",
      declare_end_date: "#{Date.today.year}1231",
      written_at: Date.today.strftime("%Y%m%d"),
      declare_type: "20",
      account_type: "02",
      residence_code: "1",
      country_code: "KR",
      foreign_tax_rate_code: "2",
    )
    individual_declare
  end
end
