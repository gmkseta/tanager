class CreateIndividualIncomeDeductions < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_income_deductions do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_income_deductions_on_declare_default_id"}

      t.string :deduction_code, limit: 2, null: false, comment: "공제감면코드"
      t.integer :deduction_amount, scale: 13, null: false, comment: "공제금액"
      t.integer :personal_deduction_count, scale: 13, comment: "인적공제명수"
      t.integer :personal_deduction_amount, scale: 60, comment: "인적기본공제금액"

      t.timestamps
    end
  end
end
