class ChangeUniqueIndexHometaxBusinessIncomes < ActiveRecord::Migration[5.2]
  def change
    remove_index :hometax_business_incomes, name: "ix_business_incomes_on_hometax_income_id_registration_type"
    add_index :hometax_business_incomes, [:hometax_individual_income_id, :registration_number, :income_type, :classficaition_code],
      name: "ix_business_incomes_on_hometax_income_id_registration_type_code", unique: true
  end
end
