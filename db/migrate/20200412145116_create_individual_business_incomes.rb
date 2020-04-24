class CreateIndividualBusinessIncomes < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_business_incomes do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_business_income_on_declare_default_id"}
      t.references :declare_user, foreign_key: true

      t.string :income_code, limit: 2, null: false, default: "40", comment: "소득구분코드"
      t.string :serial_number, limit: 6, null: false, defualt: "000001", comment: "일련번호"
      t.string :business_address, limit: 70, null: false, comment: "사업장소재지"
      t.boolean :local, null: false, defualt: true, comment: "사업장 국내/국외"
      t.string :country_code, limit: 2, null: false, default: "KR", comment: "사업장 소재지국코드"
      t.string :business_name, limit: 60, null: false, comment: "상호"
      t.string :registration_number, limit: 10, null: false, comment: "사업자번호"
      t.string :business_phone_number, limit: 10, comment: "사업장 전화번호"
      t.string :account_type, limit: 2, null: false, comment: "기장 의무 (01: 복식부기, 02: 간편장부)"
      t.string :declare_type, limit: 2, null: false, comment: "신고 유형"
      t.string :classification_code, limit: 6, null: false, comment: "주업종코드"
      t.integer :incomes, scale: 13, null: false, comment: "총수입금액"
      t.integer :expenses, scale: 13, null: false, comment: "필요경비"
      t.timestamps
    end
  end
end
