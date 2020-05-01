class AddAccountAndExpenseClassificationInBusinessExpenses < ActiveRecord::Migration[6.0]
  def change    
    add_column :business_expenses, :expense_classification_id, :integer
    add_column :business_expenses, :account_classification_id, :integer
    safety_assured { remove_column :business_expenses, :classification_id }
  end
end
