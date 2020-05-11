class AddUniqueIndexHometaxBusinessIncomes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :hometax_business_incomes, [:hometax_individual_income_id, :registration_number, :income_type],
      name: "ix_business_incomes_on_hometax_income_id_registration_type", unique: true, algorithm: :concurrently
  end
end
