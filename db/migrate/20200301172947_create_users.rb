class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :login, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :phone_number, index: { unique: true }
      t.string :email, index: { unique: true }
      t.string :password_digest

      t.timestamps
    end
    add_index :users, :name
  end
end
