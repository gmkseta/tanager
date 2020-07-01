class RemoveResidenceNumberInDeductiblePersons < ActiveRecord::Migration[5.2]
  def change
    remove_column :deductible_persons, :residence_number
  end
end
