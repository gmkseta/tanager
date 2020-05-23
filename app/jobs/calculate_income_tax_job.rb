class CalculateIncomeTaxJob < ApplicationJob
  queue_as :calculate_income_tax

  def perform(declare_user_id)
    d = DeclareUser.find(declare_user_id)
    raise "#{d.inspect} does not have hometax_individual_income" if d.hometax_individual_income.nil?
    defaults = {
        declare_user_id: declare_user_id,
        declare_type: d.apply_bookkeeping? ? "간편장부" : d.hometax_individual_income.base_expense_rate,
        account_type: d.hometax_individual_income.account_type,
        base_expense_rate: d.hometax_individual_income.base_expense_rate,
        base_ratio: d.hometax_individual_income.base_ratio_basic,
        simple_ratio: d.hometax_individual_income.simple_ratio_basic,
        owner_id: d.hometax_individual_income.owner_id,
      }
    calculated_income_tax = defaults.merge(d.calculated_tax.as_json)
    calculated_income_tax.merge!({
      personal_deduction: d.deductible_persons_sum || 0,
      pension_deduction: d.pensions_sum || 0,
      children_tax_credit_amount: d.children_tax_credit_amount || 0,
      newborn_baby_tax_credit_amount: d.newborn_baby_tax_credit_amount || 0,
      pension_account_tax_credit_amount: d.pension_account_tax_credit_amount || 0,
      retirement_pension_tax_credit_amount: d.retirement_pension_tax_credit_amount || 0
    })
    c = CalculatedIncomeTax.find_or_initialize_by(declare_user_id: d.id)
    c.assign_attributes(calculated_income_tax)
    c.save!
  end
end