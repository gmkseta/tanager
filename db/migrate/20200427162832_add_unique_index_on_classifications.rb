class AddUniqueIndexOnClassifications < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_index :classifications, [:classification_type, :name], unique: true, algorithm: :concurrently
  end
end
