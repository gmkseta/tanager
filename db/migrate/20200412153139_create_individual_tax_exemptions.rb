class CreateIndividualTaxExemptions < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_tax_exemptions do |t|
      t.references :individual_declare, foreign_key: true, index: {:name => "index_tax_exemptions_on_declare_default_id"}

      t.integer :serinal_number, scale: 6, default: 1, null: false, comment: "일련번호"
      t.string :tax_exemption_code, limit: 3, null: false, comment: "세액감면코드"
      t.integer :tax_exemption_amount, scale: 15, default: 0, null: false, comment: "세액감면"
      t.string :registration_number, limit: 10, null: false, comment: "사업자등록번호"
      t.timestamps
    end
  end
end
