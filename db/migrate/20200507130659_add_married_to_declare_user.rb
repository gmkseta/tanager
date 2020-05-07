class AddMarriedToDeclareUser < ActiveRecord::Migration[6.0]
  def change
    add_column :declare_users, :married, :boolean
  end
end
