class CreateBusinessExpenses < ActiveRecord::Migration[6.0]
  def change
    create_table :business_expenses do |t|
      t.references :declare_user, null: false, foreign_key: true
      t.references :classification, null: false, foreign_key: true
      t.integer :amount, null: false
      t.string :memo

      t.timestamps
    end
  end
end
