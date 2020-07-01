class AddEncryptedResidenceNumberInDeductiblePersons < ActiveRecord::Migration[5.2]
  def change
    add_column :deductible_persons, :encrypted_residence_number, :string
    add_column :deductible_persons, :encrypted_residence_number_iv, :string
  end
end
