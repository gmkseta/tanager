class CreateEstimatedCalulatedIncomeTaxes < ActiveRecord::Migration[5.2]
  def change
    create_table :estimated_calulated_income_taxes do |t|
      t.bigint :owner_id, null: false
      t.integer :year, null: false
      t.string :account_type, null: false
      t.string :base_expense_rate, null: false
      t.float :base_ratio, null: false
      t.float :simple_ratio, null: false
      t.bigint :business_incomes, null: false
      t.bigint :expenses, null: false
      t.bigint :total_income, null: false
      t.integer :income_deduction, null: false
      t.integer :personal_deduction, null: false
      t.integer :personal_pension_deduction
      t.integer :merchant_pension_deduction
      t.integer :national_pension_deduction
      t.integer :online_declare_credit_amount
      t.integer :children_tax_credit_amount
      t.integer :newborn_baby_tax_credit_amount
      t.integer :pension_account_tax_credit_amount
      t.integer :retirement_pension_tax_credit_amount
      t.integer :base_taxation, null: false
      t.float :tax_rate, null: false
      t.integer :calculated_tax, null: false
      t.integer :tax_exemption, null: false
      t.integer :tax_credit, null: false
      t.integer :determined_tax, null: false
      t.integer :penalty_tax, null: false
      t.integer :prepaid_tax, null: false
      t.integer :payment_tax, null: false
      t.integer :payment_local_tax, null: false

      t.timestamps
    end
    add_index :estimated_calulated_income_taxes, [:owner_id, :year], unique: true
  end
end
