class AddUniqueIndexInHometaxIndividualIncomes < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change    
    add_index :hometax_individual_incomes, [:declare_user_id, :declare_year],
      name: "index_hometax_individual_incomes_on_declare_user_id_and_year", unique: true, where: "declare_user_id IS NOT NULL", algorithm: :concurrently
    add_index :hometax_individual_incomes, [:owner_id, :declare_year], unique: true, where: "owner_id IS NOT NULL", algorithm: :concurrently
  end
end
