class CreateSimplifiedBookkeepings < ActiveRecord::Migration[6.0]
  def change
    create_table :simplified_bookkeepings do |t|
      t.references :declare_user, null: false, foreign_key: true
      t.integer :business_id
      t.integer :public_id
      t.string :registration_number, null: false, comment: "사업자번호"
      t.string :vendor_registration_number, comment: "거래처 사업자번호"
      t.string :vendor_business_name, comment: "거래처 사업자명"
      t.string :vendor_hometax_classification_code, comment: "거래처 홈택스코드"
      t.string :purchase_type, comment: "구매타입"
      t.string :account_classification_code, comment: "계정과목코드"
      t.string :account_classification_name, comment: "계정과목명"
      t.integer :amount, null: false, comment: "총 합계"
      t.integer :purchases_count, null: false, comment: "구매 수"      

      t.timestamps
    end
    add_index :simplified_bookkeepings, [:registration_number, :vendor_registration_number, :purchase_type],
      name: "ix_simplified_bookkeepings_on_purchases_and_registration_number",
      unique: true, where: "vendor_registration_number IS NOT NULL"
    add_index :simplified_bookkeepings, [:registration_number, :vendor_business_name, :purchase_type],
      name: "ix_simplified_bookkeepings_on_purchases_and_registration_name",
      unique: true, where: "vendor_registration_number IS NULL"
  end
end
