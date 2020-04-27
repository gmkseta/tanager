class CreateRegNumClassificationCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :registration_number_classification_codes do |t|
      t.string :registration_number, limit: 10, null: false, comment: "사업자등록번호", index: {unique: true}
      t.string :classification_code, limit: 6, null: false, comment: "주업종코드"
      t.string :classification_name, limit: 64, null: false, comment: "주업종명"

      t.timestamps
    end
  end
end
