class AddDescriptionInClassifications < ActiveRecord::Migration[6.0]
  def change
    add_column :classifications, :description, :string
  end
end
