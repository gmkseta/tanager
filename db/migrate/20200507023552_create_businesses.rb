class CreateBusinesses < ActiveRecord::Migration[6.0]
  def change
    create_table :businesses do |t|
      t.references :user
      t.string :name, null: false
      t.string :registration_number, null: false
      t.string :address, null: false
      t.integer :public_id, null: false
      t.integer :owner_id, null: false
      t.string :login
      t.string :hometax_classification_code
      t.string :taxation_type
      t.datetime :opened_at
      t.string :official_name
      t.string :official_code
      t.string :official_number

      t.timestamps
    end
  end
end
