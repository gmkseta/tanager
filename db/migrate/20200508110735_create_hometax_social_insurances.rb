class CreateHometaxSocialInsurances < ActiveRecord::Migration[6.0]
  def change
    create_table :hometax_social_insurances do |t|
      t.references :declare_user, foreign_key: true
      t.bigint :owner_id, null: false
      t.string :registration_number
      t.string :business_name
      t.string :insurance_type, null: false
      t.integer :amount, null: false
      t.integer :year

      t.timestamps
    end
    add_index :hometax_social_insurances, [:owner_id, :insurance_type, :year],
    name: "index_hometax_social_insurances_on_owner_type_and_year", unique: true
  end
end
