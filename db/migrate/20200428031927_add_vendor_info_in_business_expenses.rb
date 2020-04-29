class AddVendorInfoInBusinessExpenses < ActiveRecord::Migration[6.0]
  def change
    add_column :business_expenses, :vendor_name, :string
    add_column :business_expenses, :vendor_registration_number, :string
    add_column :business_expenses, :written_at, :integer        
  end
end
