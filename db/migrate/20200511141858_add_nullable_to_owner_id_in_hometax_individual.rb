class AddNullableToOwnerIdInHometaxIndividual < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    remove_index :hometax_individual_incomes, name: "index_hometax_individual_incomes_on_owner_id_and_declare_year"
    remove_index :hometax_individual_incomes, name: "index_hometax_individual_incomes_on_declare_user_id_and_year"

    change_column_null :hometax_individual_incomes, :owner_id, false
    change_column_null :hometax_individual_incomes, :declare_year, false

    add_index :hometax_individual_incomes, [:owner_id, :declare_year], unique: true, algorithm: :concurrently
  end
end
