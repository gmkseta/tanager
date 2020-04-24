class CreateIndividualTaxCredits < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_tax_credits do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_tax_credits_on_declare_default_id"}

      t.integer :serinal_number, scale: 6, default: 1, null: false, comment: "일련번호"
      t.string :tax_credit_code, limit: 3, null: false, comment: "세액공제코드"
      t.integer :base_amount, scale: 15, default: 0, null: false, comment: "공제대상금액"
      t.integer :amount, scale: 15, default: 0, null: false, comment: "공제금액"
      t.string :registration_number, limit: 10, null: false, comment: "사업자등록번호"

      t.timestamps
    end
  end
end
