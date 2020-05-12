class AddClosedAtAndClassificatioNameInBusiness < ActiveRecord::Migration[5.2]
  def change
    add_column :businesses, :closed_at, :date
    add_column :businesses, :hometax_classification_name, :string
  end
end
