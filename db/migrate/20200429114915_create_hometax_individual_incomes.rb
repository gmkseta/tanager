class CreateHometaxIndividualIncomes < ActiveRecord::Migration[6.0]
  def change
    create_table :hometax_individual_incomes do |t|
      t.references :declare_user, null: false, foreign_key: true
      t.string :name, null: false, comment: "이름"
      t.string :birthday, null: false, comment: "생년월일"
      t.string :declare_type, null: false, comment: "신고안내유형"
      t.string :account_type, null: false, comment: "기장의무구분"
      t.string :base_expense_rate, null: false, comment: "추계신고시 적용경비율"
      t.string :declare_year, null: false, comment: "귀속년도"

      t.boolean :interest_income, null: false, comment: "이자소득"
      t.boolean :dividend_income, null: false, comment: "배당소득"
      t.boolean :wage_single_income, null: false, comment: "근로소득(단일)"
      t.boolean :wage_multiple_income, null: false, comment: "근로소득(복수)"
      t.boolean :pension_income, null: false, comment: "연금소득"
      t.boolean :other_income, null: false, comment: "기타소득"
      t.boolean :religions_income, null: false, comment: "종교인기타소득"
      t.boolean :yearend_settlement_income, null: false, comment: "사업연말정산소득"

      t.integer :prepaid_tax, null: false, comment: "기납부세액"
      t.integer :national_pension, null: false, comment: "국민연금보험료"
      t.integer :personal_pension, null: false, comment: "개인연금저축"
      t.integer :merchant_pension, null: false, comment: "소기업소상공인공제부금"
      t.integer :retirement_pension_tax_credit, null: false, comment: "퇴직연금세액공제"
      t.integer :pension_account_tax_credit, null: false, comment: "연금계좌세액공제"

      t.string :declare_penalty_case, null: false, comment: "무신고 또는 무기장가산세"
      t.integer :unfaithful_report_invoice_amount, null: false, comment: "(세금)계산서관련 보고불성실"
      t.string :not_register_cash_receipts, null: false, comment: "현금영수증미가맹"
      t.integer :not_issued_cash_receipts_amount, null: false, comment: "현금영수증미발급 금액"
      t.integer :decline_cash_receipts_count, null: false, comment: "현금영수증발급거부(10만미만)"
      t.integer :decline_cash_receipts_amount, null: false, comment: "현금영수증발급거부(10만이상)"
      t.integer :decline_cards_count, null: false, comment: "신용카드발급거부(10만미만)"
      t.integer :decline_cards_amount, null: false, comment: "신용카드발급거부(10만이상)"
      t.integer :unfaithful_business_report_amount, null: false, comment: "사업장현황신고불성실"
      t.string :no_business_account_penalty, null: false, comment: "사업용계좌미신고"

      t.timestamps
    end
    add_index :hometax_individual_incomes, [:declare_user_id, :declare_year],
      name: "index_hometax_individual_incomes_on_declare_user_id_and_year", unique: true
  end
end
