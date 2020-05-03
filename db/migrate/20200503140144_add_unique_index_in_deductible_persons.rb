class AddUniqueIndexInDeductiblePersons < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_index :deductible_persons, [:declare_user_id, :residence_number], 
    name: "ix_deductible_persons_on_declare_user_id_and_residence_number", unique: true, algorithm: :concurrently
  end
end
