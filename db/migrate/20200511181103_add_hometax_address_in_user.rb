class AddHometaxAddressInUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :hometax_address, :string
  end
end
