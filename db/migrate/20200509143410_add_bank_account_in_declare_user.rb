class AddBankAccountInDeclareUser < ActiveRecord::Migration[5.2]
  def change
    add_column :declare_users, :bank_account_number, :string
    add_column :declare_users, :bank_code, :string
  end
end
