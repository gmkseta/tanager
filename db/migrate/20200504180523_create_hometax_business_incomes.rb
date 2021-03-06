class CreateHometaxBusinessIncomes < ActiveRecord::Migration[6.0]
  def change
    create_table :hometax_business_incomes do |t|
      t.references :hometax_individual_income, null: false, foreign_key: true
      t.string :registration_number, comment: "사업자등록번호"
      t.string :business_name, null: false, comment: "상호"      
      t.string :income_type, null: false, comment: "수입종류구분코드"
      t.string :classficaition_code, null: false, comment: "업종코드"
      t.string :business_type, null: false, comment: "사업형태"
      t.string :account_type, null: false, comment: "기장의무"
      t.integer :income_amount, null: false, comment: "수입금액"
      t.float :base_ratio_basic, null: false, comment: "기준경비율(일반)"
      t.float :base_ratio_self, null: false, comment: "기준경비율(자가)"
      t.float :simple_ratio_basic, null: false, comment: "단순경비율(일반)"
      t.float :simple_ratio_self, null: false, comment: "단순경비율(자가)"
      t.string :wht_agent, comment: "주요원천징수의무자"

      t.timestamps
    end
  end
end
