class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :login, index: { unique: true }
      t.string :password_digest, null: false
      t.string :name
      t.string :phone_number
      t.string :hometax_account

      t.timestamps
    end
  end
end
