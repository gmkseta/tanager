class DropAndNewIssuedAtToDate < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :business_expenses, :written_at }
    add_column :business_expenses, :issued_at, :date
  end
end
