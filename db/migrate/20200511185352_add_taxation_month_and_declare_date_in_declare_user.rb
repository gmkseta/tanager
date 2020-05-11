class AddTaxationMonthAndDeclareDateInDeclareUser < ActiveRecord::Migration[5.2]
  def change
    add_column :declare_users, :taxation_month, :date
    add_column :declare_users, :declare_date, :date
  end
end
