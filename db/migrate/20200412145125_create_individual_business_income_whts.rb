class CreateIndividualBusinessIncomeWhts < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_business_income_whts do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_business_income_whts_on_declare_default_id"}

      t.string :business_residence_number, limit: 13, null: false, comment: "사업자 주민등록번호"
      t.string :serinal_number, limit: 6, null: false, defualt: "000001", comment: "일련번호"
      t.string :business_name, limit: 60, null: false, comment: "상호"
      t.integer :income_tax, scale: 13, comment: "소득세"
      t.integer :farming_tax, scale: 13, null: false, comment: "농특세"
      t.boolean :is_business, null: false, comment: "사업자주민구분"
      t.timestamps
    end
  end
end
