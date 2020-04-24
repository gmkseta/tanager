class CreateIndividualPersonalDeductions < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_personal_deductions do |t|      
      t.references :individual_declare, foreign_key: true, index: {:name => "index_personal_deductions_on_declare_default_id"}

      t.string :residence_number, limit: 13, null: false, comment: "주민등록번호"
      t.string :name, limit: 30, null: false, comment: "성명"
      t.string :relation_code, limit: 1, null: false, comment: "관계코드"
      t.string :relation_name, limit: 20, null: false, comment: "관계"
      t.boolean :elder, null: false, default: false, comment: "경로자여부"
      t.boolean :disabled, null: false, default: false, comment: "장애인여부"
      t.boolean :woman_deduction, null: false, default: false, comment: "부녀자여부"
      t.boolean :child, null: false, default: false, comment: "6세이하자여부"
      t.boolean :single_parent, null: false, default: false, comment: "한부모가족공제여부"
      t.boolean :foreign, null: false, default: false, comment: "내외국구분코드"
      t.boolean :default_deduction, null: false, default: false, comment: "기본공제여부"

      t.timestamps
    end
  end
end
