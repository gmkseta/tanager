class CreateDeclareUsers < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        safety_assured { execute "CREATE TYPE decalre_tax_type AS ENUM('income', 'vat', 'wht')" }
      end
      dir.down do
        safety_assured { execute "DROP TYPE decalre_tax_type" }
      end
    end

    create_table :declare_users do |t|
      t.references :user, foreign_key: true
      t.column :declare_tax_type, :decalre_tax_type, null: false, comment: "income/vat/wht"
      t.string :encrypted_residence_number
      t.string :encrypted_residence_number_iv
      t.string :hometax_account, null: false, limit: 13, comment: "홈택스ID"
      t.string :name, null: false, limit: 30, comment: "납세자 이름"
      t.string :address, null: false, limit: 70, comment: "납세자 주소"
      t.string :phone_number, limit: 14, comment: "주소지전화번호"
      t.string :business_phone_number, limit: 14, comment: "사업장전화번호"
      t.string :cellphone_number, limit: 14, comment: "휴대전화번호"
      t.string :email, limit: 50, comment: "전자메일주소"

      t.timestamps
    end
  end
end
