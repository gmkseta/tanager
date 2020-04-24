class CreateTaxAccountants < ActiveRecord::Migration[6.0]
  def change
    create_table :tax_accountants do |t|
      t.string :name, limit: 30, null: false, comment: "세무대리인성명"
      t.string :residence_number, limit: 13, null: false, comment: "세무대리인주민등록번호"
      t.string :phone_number, limit: 14, comment: "세무대리인전화번호"
      t.string :registration_number, limit: 10, null: false, comment: "세무대리인사업자등록번호"

      t.timestamps
    end
  end
end
