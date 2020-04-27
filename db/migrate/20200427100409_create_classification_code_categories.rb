class CreateClassificationCodeCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :classification_code_categories do |t|
      t.string :classification_code, limit: 6, null: false, comment: "주업종코드", index: {unique: true}
      t.string :category, limit: 32, null: false, comment: "내부업종분류"

      t.timestamps
    end
  end
end
