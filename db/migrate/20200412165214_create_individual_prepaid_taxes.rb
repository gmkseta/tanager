class CreateIndividualPrepaidTaxes < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_prepaid_taxes do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_prepaid_taxes_on_declare_default_id"}

      t.string :interim_prepayment, limit: 14, null: false, comment: "중간예납세액 소득"
      t.string :sales_land_prepaid_amont, limit: 14, null: false, comment: "토지등매매차익예정신고납부세액_소득"
      t.string :sales_land_pre_notice_amont, limit: 14, null: false, comment: "토지등매매차익예정고지세액_소득"
      t.string :frequently_assessed_amount, limit: 14, null: false, comment: "수시부과세_소득"
      
      t.string :interest_income_wht, limit: 14, null: false, comment: "원천징수 이자소득"
      t.string :dividend_income_wht, limit: 14, null: false, comment: "원천징수 배당소득"
      t.string :business_income_wht, limit: 14, null: false, comment: "원천징수 사업소득"
      t.string :wage_income_wht, limit: 14, null: false, comment: "원천징수 근로소득"
      t.string :pension_income_wht, limit: 14, null: false, comment: "원천징수 연금소득"
      t.string :other_income_wht, limit: 14, null: false, comment: "원천징수 기타소득"
      t.string :sum_prepaid_amount, limit: 14, null: false, comment: "기납부세액합계_소득"

      t.timestamps
    end
  end
end
