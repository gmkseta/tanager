class AddNullableFieldsInDeclareUser < ActiveRecord::Migration[5.2]
  def change
    change_column_null :declare_users, :hometax_account, true
    change_column_null :declare_users, :name, true
    change_column_null :declare_users, :address, true
  end
end
