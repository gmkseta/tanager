class AddUniqueIndexToDeclareUser < ActiveRecord::Migration[5.2]
  def change
    add_index :declare_users, [:user_id, :declare_tax_type, :taxation_month],
      name: "index_decalre_users_on_user_and_tax_type_and_taxation_month", unique: true
    add_foreign_key :declare_users, :users, column: :user_id, on_delete: :cascade
  end
end
