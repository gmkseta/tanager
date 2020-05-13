class ChangeBigIntToAmountInExpenses < ActiveRecord::Migration[5.2]
  def change
    change_column :business_expenses, :amount, :bigint
    change_column :simplified_bookkeepings, :amount, :bigint
  end
end
