class CreateIndividualSpecialTaxationIncomeDeductions < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_special_taxation_income_deductions do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_special_taxation_income_on_declare_default_id"}

      t.integer :serinal_number, scale: 6, default: 1, null: false, comment: "일련번호"
      t.string :deduction_code, limit: 3, null: false, comment: "소득공제코드"
      t.integer :deduction_amount, scale: 15, default: 0, null: false, comment: "공제세액"
      t.string :registration_number, limit: 10, null: false, comment: "사업자등록번호"
      t.timestamps
    end
  end
end
