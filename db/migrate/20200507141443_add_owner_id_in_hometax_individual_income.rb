class AddOwnerIdInHometaxIndividualIncome < ActiveRecord::Migration[6.0]
  def change
    add_column :hometax_individual_incomes, :owner_id, :bigint
    add_column :hometax_individual_incomes, :hometax_account, :string
    change_column_null :hometax_individual_incomes, :declare_user_id, true
    remove_index :hometax_individual_incomes, name: "index_hometax_individual_incomes_on_declare_user_id_and_year"
  end
end
