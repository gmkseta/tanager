class CreateIndividualCalculatedTaxes < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_calculated_taxes do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_calculated_taxes_on_declare_default_id"}

      t.integer :total_income, scale: 13, default: 0, null: false, comment: "종합소득금액"
      t.integer :income_deduction, scale: 13, default: 0, null: false, comment: "소득공제"
      t.integer :base_taxation, scale: 15, default: 0, null: false, comment: "종합소득세 과세표준"
      t.float :tax_rate, precision: 5, scale: 2, null: false, comment: "종합소득세 세율"
      t.integer :calculated_tax, scale: 15, default: 0, null: false, comment: "종합소득세 산출세액"
      t.integer :tax_exemption, scale: 15, default: 0, null: false, comment: "종합소득세 세액감면"
      t.integer :tax_credit_amount, scale: 15, default: 0, null: false, comment: "종합소득세 세액공제"
      t.integer :determined_tax_taxation, scale: 15, default: 0, null: false, comment: "종합소득세 결정세액 종합과세"
      t.integer :determined_tax_estate_income, scale: 15, default: 0, null: false, comment: "종합소득세 결정세액 분리과세주택임대소득"
      t.integer :determined_tax_sum, scale: 15, default: 0, null: false, comment: "종합소득세 결정세액 합계"
      t.integer :additional_tax, scale: 15, default: 0, null: false, comment: "종합소득세 가산세"
      t.integer :extra_tax, scale: 13, default: 0, null: false, comment: "종합소득세 추가납부세액"
      t.integer :total_amount, scale: 13, default: 0, null: false, comment: "종합소득세 합계"
      t.integer :prepaid_amount, scale: 15, default: 0, null: false, comment: "종합소득세 기납부세액"
      t.integer :payment_tax, scale: 15, default: 0, null: false, comment: "종합소득세 납부할세액"
      t.integer :payment_deducted_tax, scale: 15, default: 0, null: false, comment: "종합소득세 납부할세액 차감"
      t.integer :payment_additional_tax, scale: 15, default: 0, null: false, comment: "종합소득세 납부할세액 가산"
      t.integer :installment_tax, scale: 15, default: 0, null: false, comment: "종합소득세 분납할세액"
      t.integer :declare_period_payment_tax, scale: 15, default: 0, null: false, comment: "종합소득세 신고기한내 납부할세액"

      t.timestamps
    end
  end
end
