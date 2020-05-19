class ChangeLengthHomtaxAccountInDeclareUser < ActiveRecord::Migration[5.2]
  def change
    change_column :declare_users, :hometax_account, :string, :limit => 63
  end
end
