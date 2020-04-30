class AddAccountClassificationIdInAccountClassificaitionRules < ActiveRecord::Migration[6.0]  
  disable_ddl_transaction!

  def change
    add_reference :account_classification_rules, :classification, index: {algorithm: :concurrently}
  end
end
