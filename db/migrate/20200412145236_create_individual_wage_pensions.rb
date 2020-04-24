class CreateIndividualWagePensions < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_wage_pensions do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_wage_pensions_on_declare_default_id"}

      t.string :income_code, length: 2, null: false, comment: "소득구분코드"
      t.string :serinal_number, length: 6, null: false, defualt: "000001", comment: "일련번호"
      t.string :employer_business_name, length: 60, comment: "소득지급자_상호"
      t.string :employer_registration_number, length: 13, comment: "소득지급자_사업자등록번호"
      t.integer :income_amount, scale: 13, null: false, comment: "총수입금액(총급여액)"
      t.integer :profit_amount, scale: 13, null: false, comment: "필요경비(근로소득공제)"
      t.integer :income, scale: 13, null: false, comment: "소득금액"
      t.integer :wht_income_tax, scale: 13, null: false, comment: "원천징수_소득세"
      t.integer :wht_farm_tax, scale: 13, null: false, comment: "원천징수_농득세"      
      t.timestamps
    end
  end
end
