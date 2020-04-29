class CreateDeductiblePersons < ActiveRecord::Migration[6.0]
  def change
    create_table :deductible_persons do |t|
      t.references :declare_user, null: false, foreign_key: true
      t.references :classification, null: false, foreign_key: true
      t.string :residence_number, limit: 13, null: false, comment: "주민등록번호"
      t.string :name, limit: 30, null: false, comment: "성명"
      t.boolean :disabled, null: false, defalt: false, comment: "장애인여부"
      t.boolean :woman_deduction, null: false, defalt: false, comment: "부녀자여부"
      t.boolean :single_parent, null: false, defalt: false, comment: "한부모가족공제여부"
      t.boolean :basic_livelihood, null: false, defalt: false, comment: "수급자"

      t.timestamps
    end
  end
end
