class AddNullableInHometaxIndividualIncomes < ActiveRecord::Migration[6.0]
  def change
    change_column_null :hometax_individual_incomes, :declare_penalty_case, true
    change_column_null :hometax_individual_incomes, :no_business_account_penalty, true
    change_column_null :hometax_individual_incomes, :not_register_cash_receipts, true
  end
end
