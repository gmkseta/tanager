class AddDatetimeToBusinessExpenses < ActiveRecord::Migration[6.0]
  def change
    safety_assured { remove_column :business_expenses, :written_at }
    add_column :business_expenses, :written_at, :datetime
  end
end
