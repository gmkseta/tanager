class CreateHometaxIndividualIncomes < ActiveRecord::Migration[6.0]
  def change
    create_table :hometax_individual_incomes do |t|
      t.string :name, null: false, comment: "이름"
      t.string :birthday, null: false, comment: "생년월일"
      t.string :declare_type, null: false, comment: "신고안내유형"
      t.string :account_type, null: false, comment: "기장의무구분"
      t.string :base_expense_rate, null: false, comment: "추계신고시 적용경비율"
      t.string :delcare_year, null: false, comment: "귀속년도"

      t.boolean :interest_income, null: false, comment: "이자소득"
      t.boolean :dividend_income, null: false, comment: "배당소득"
      t.boolean :business_income, null: false, comment: "사업소득"
      t.boolean :wage_single_income, null: false, comment: "근로소득(단일)"
      t.boolean :wage_multiple_income, null: false, comment: "근로소득(복수)"
      t.boolean :pension_income, null: false, comment: "연금소득"
      t.boolean :other_income, null: false, comment: "기타소득"

      t.integer :prepaid_tax, null: false, comment: "기납부세액"
      t.integer :national_pension, null: false, comment: "국민연금보험료"
      t.integer :personal_pension, null: false, comment: "개인연금저축"
      t.integer :merchant_pension, null: false, comment: "소기업소상공인공제부금"
      t.integer :retirement_pension_tax_credit, null: false, comment: "퇴직연금세액공제"
      t.integer :pension_account_tax_credit, null: false, comment: "연금계좌세액공제"

      t.integer :no_declare_penalty, null: false, comment: "무신고 또는 무기장가산세"
      t.integer :unfaithful_report_invoice_penalty, null: false, comment: "(세금)계산서관련 보고불성실"
      t.integer :no_cash_receipits_penalty, null: false, comment: "현금영수증미가맹"
      t.integer :less_decline_cash_receipits_penalty, null: false, comment: "현금영수증발급거부(10만미만)"
      t.integer :more_decline_cash_receipits_penalty, null: false, comment: "현금영수증발급거부(10만이상)"
      t.integer :less_decline_card_penalty, null: false, comment: "신용카드발급거부(10만미만)"
      t.integer :more_decline_card_penalty, null: false, comment: "신용카드발급거부(10만이상)"
      t.integer :no_business_report_penalty, null: false, comment: "사업장현황신고불성실"
      t.integer :no_business_account_penalty, null: false, comment: "사업용계좌미신고"

      t.timestamps
    end
  end
end
