class DropHometaxBusinessExpenses < ActiveRecord::Migration[6.0]
  def change
    drop_table :hometax_business_expenses
  end
end
