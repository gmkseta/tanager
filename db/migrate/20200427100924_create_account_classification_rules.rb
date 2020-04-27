class CreateAccountClassificationRules < ActiveRecord::Migration[6.0]
  def change
    create_table :account_classification_rules do |t|
      t.string :category, limit: 32, null: false, comment: "내부업종분류"
      t.string :classification_code, limit: 6, null: false, comment: "주업종코드. 앞 2자리 사용"
      t.string :account_classification_code, limit: 6, null: false, comment: "계정과목분류코드", index: {name: "ix_account_classification_rules_on_account_classification_code", unique: true}
      t.string :account_classification_name, limit: 32, null: false, comment: "계정과목분류명"

      t.timestamps
    end
  end
end
