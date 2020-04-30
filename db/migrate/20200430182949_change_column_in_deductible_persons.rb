class ChangeColumnInDeductiblePersons < ActiveRecord::Migration[6.0]
  def change
    change_column_null :deductible_persons, :disabled, true
    change_column_null :deductible_persons, :woman_deduction, true
    change_column_null :deductible_persons, :single_parent, true
    safety_assured { remove_column :deductible_persons, :basic_livelihood }
  end
end
