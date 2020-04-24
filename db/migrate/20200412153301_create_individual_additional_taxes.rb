class CreateIndividualAdditionalTaxes < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_additional_taxes do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_additional_taxes_on_declare_default_id"}

      t.string :additional_tax_code, limit: 14, null: false, comment: "가산세코드"
      t.integer :denominator, scale: 6, default: 0, null: false, comment: "가산세적용분모수"
      t.integer :numerator, scale: 5, default: 0, null: false, comment: "가산세적용분자수"
      t.integer :apply_date_count, scale: 5, default: 0, null: false, comment: "가산세적용일수"
      t.integer :base_amount, scale: 15, default: 0, null: false, comment: "기준금액"
      t.integer :amount, scale: 15, default: 0, null: false, comment: "가산세액"

      t.timestamps
    end
  end
end
