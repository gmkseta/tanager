class ReplaceUniqueIndexOnAccountClassificationRules < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    remove_index :account_classification_rules, name: "ix_account_classification_rules_on_account_classification_code"
    add_index :account_classification_rules, [:category, :classification_code, :account_classification_code],
              name: "ix_account_classification_rules_on_account_classification_code", unique: true, algorithm: :concurrently
  end
end
