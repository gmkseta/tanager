class AddStatusOnDeclareUser < ActiveRecord::Migration[6.0]
  def change
    add_column :declare_users, :status, :integer
  end
end
