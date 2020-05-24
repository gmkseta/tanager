class EstimateIncomeTaxJob < ApplicationJob
  queue_as :estimate_income_tax

  def perform(owner_id)
    h = HometaxIndividualIncome.find_by(owner_id: owner_id)
    expenses = h.expenses_sum_by_ratio
    if h.base_expense_rate.eql?("기준경비율")
      u = Snowdon::User.find(owner_id)
      amount = 0
      u.hometax_businesses.each do |h_b|
        raise "#{h_b.inspect} is not able to find classification_code" if (h_b.classification_code.nil?) || 
             (ClassificationCodeCategory.find_by(classification_code: h_b.classification_code).nil?)
        calculated_expenses = h_b.business.calculate(nil).select {
          |d| d[:deductible] == true
          }.map{
            |c| c[:amount]
          }.sum
        amount += calculated_expenses
        amount += h_b.business.wage
        amount += HometaxSocialInsurance.where(owner_id: u.id)
                    .where(registration_number: h_b.business.registration_number)
                    .businesses.last_year.sum(:amount)
        amount += HometaxSocialInsurance.where(owner_id: u.id).local_insurances_sum
      end
      expenses = amount
    end
    income_deduction = 1500000 + h.personal_pension_deduction + h.national_pension
    calculated_tax_by_ratio = IndividualIncome::CalculatedTax.new(
      business_incomes: h.business_income_sum,
      expenses: expenses,
      income_deduction: income_deduction,
      tax_exemption: 0,
      tax_credit: 70000,
      penalty_tax: 0,
      prepaid_tax: 0,
    )
    e = EstimatedCalulatedIncomeTax.create!(
      calculated_tax_by_ratio.as_json.merge({
        account_type: h.account_type,
        base_expense_rate: h.base_expense_rate,
        base_ratio: h.base_ratio_basic,
        simple_ratio: h.simple_ratio_basic,
        owner_id: h.owner_id,
        year: 2019,
        income_deduction: 1500000,
        personal_deduction: 1500000,
        online_declare_credit_amount: 20000,
      })
    )
  end
end
