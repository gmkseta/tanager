class CreateUserAccountClassificationRules < ActiveRecord::Migration[6.0]
  def change
    create_table :user_account_classification_rules do |t|
      t.references :declare_user, null: false, foreign_key: true
      t.references :classification, null: false, foreign_key: true

      t.string :vendor_registration_number, null: false
      t.string :purchase_type, null: false

      t.boolean :deductible

      t.timestamps
    end
    add_index :user_account_classification_rules, [:declare_user_id, :vendor_registration_number, :purchase_type],
              name: "index_user_classification_rules_on_user_and_business_and_type", unique: true
  end
end
