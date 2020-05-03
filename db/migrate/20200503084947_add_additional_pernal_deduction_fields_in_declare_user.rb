class AddAdditionalPernalDeductionFieldsInDeclareUser < ActiveRecord::Migration[6.0]
  def change
    add_column :declare_users, :disabled, :boolean, comment: "장애인여부"
    add_column :declare_users, :woman_deduction, :boolean, comment: "부녀자여부"
    add_column :declare_users, :single_parent, :boolean, comment: "한부모가족공제여부"
  end
end
