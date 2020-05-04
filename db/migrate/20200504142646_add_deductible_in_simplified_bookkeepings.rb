class AddDeductibleInSimplifiedBookkeepings < ActiveRecord::Migration[6.0]
  def change
    add_column :simplified_bookkeepings, :deductible, :boolean
  end
end
