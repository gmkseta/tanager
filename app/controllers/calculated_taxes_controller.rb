class CalculatedTaxesController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user
  def index    
    render json: {
      base_expense_rate: @declare_user.hometax_individual_income.base_expense_rate,
      expense_ratio: @declare_user.hometax_individual_income.expenses_ratio,
      declare_from: Date.today.last_year.beginning_of_year.strftime,
      declare_to: Date.today.last_year.end_of_year.strftime,
      declare_user: @declare_user.as_json(except: DeclareUser::EXCEPT_JSON_FIELD),
      calculated_taxes: {
        calculated_tax_by_bookkeeping: @declare_user.calculated_tax_by_bookkeeping.as_json,
        calculated_tax_by_ratio: @declare_user.calculated_tax_by_ratio.as_json,
      } 
    }, status: :ok
  end

  def deductions
    render json: {
      total_amount: @declare_user.deductible_persons.sum(&:deduction_amount) + @declare_user.deduction_amount + @declare_user.pensions_sum,
      personal_deduction: {
        total_amount: @declare_user.deductible_persons.sum(&:deduction_amount) + @declare_user.deduction_amount,
        self_count: 1,
        self_base_amount: 1500000,
        spouse_count: @declare_user.deductible_persons.select {|s| s.spouse? }.length,
        spouse_base_amount: 1500000,
        dependants_count: @declare_user.deductible_persons.dependants_count,
        dependants_base_amount: 1500000,
        elder_count: @declare_user.deductible_persons.elder_count + (@declare_user.elder? ? 1 : 0),
        elder_base_amount: 1000000,
        disabled_count: @declare_user.deductible_persons.disabled_count + (@declare_user.disabled ? 1 : 0),
        disabled_base_amount: 2000000,
        single_parent_count: @declare_user.deductible_persons.single_parent_count + (@declare_user.single_parent ? 1 : 0),
        single_parent_base_amount: 1000000,
        woman_deduction_count: @declare_user.deductible_persons.woman_deduction_count + (@declare_user.woman_deduction ? 1 : 0),
        woman_deduction_base_amount: 500000,
      },
      pension_deduction: {
        total_amount: @declare_user.pensions_sum,
        personal_pension_deduction: @declare_user.hometax_individual_income.personal_pension_deduction,
        merchant_pension_deduction: @declare_user.hometax_individual_income.merchant_pension_deduction,
        national_pension_deduction: @declare_user.hometax_individual_income.national_pension,

      }
    }, status: :ok
  end

  def tax_credits
    render json: {
      total_amount: @declare_user.tax_credit_amount,
      tax_credits: {
        children_tax_credit_amount: @declare_user.children_tax_credit_amount,
        newborn_baby_tax_credit_amount: @declare_user.newborn_baby_tax_credit_amount,
        pensions_tax_credit_amount: @declare_user.pensions_tax_credit_amount,
      }
    }, status: :ok
  end

  def tax_exemptions
    render json: {
      total_amount: @declare_user.tax_exemption_amount,
      tax_exemptions: {
        base_tax_exemption: @declare_user.base_tax_exemption,
        online_declare_exemption: 20000,
      }
    }, status: :ok
  end
end
