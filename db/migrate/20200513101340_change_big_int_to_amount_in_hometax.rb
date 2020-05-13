class ChangeBigIntToAmountInHometax < ActiveRecord::Migration[5.2]
  def change
    change_column :hometax_business_incomes, :income_amount, :bigint
    change_column :hometax_individual_incomes, :prepaid_tax, :bigint
    change_column :hometax_individual_incomes, :national_pension, :bigint
    change_column :hometax_individual_incomes, :personal_pension, :bigint
    change_column :hometax_individual_incomes, :merchant_pension, :bigint
    change_column :hometax_individual_incomes, :retirement_pension_tax_credit, :bigint
    change_column :hometax_individual_incomes, :pension_account_tax_credit, :bigint
    change_column :hometax_individual_incomes, :unfaithful_report_invoice_amount, :bigint
    change_column :hometax_individual_incomes, :not_issued_cash_receipts_amount, :bigint
    change_column :hometax_individual_incomes, :decline_cash_receipts_amount, :bigint    
    change_column :hometax_individual_incomes, :decline_cards_amount, :bigint
    change_column :hometax_individual_incomes, :unfaithful_business_report_amount, :bigint
  end
end
