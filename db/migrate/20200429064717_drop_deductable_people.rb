class DropDeductablePeople < ActiveRecord::Migration[6.0]
  def change
    drop_table :deductable_people
  end
end
