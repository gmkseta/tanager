class CreateClassifications < ActiveRecord::Migration[6.0]
  def change
    create_table :classifications do |t|
      t.string :classification_type
      t.string :name
      t.string :slug
      t.integer :parent_id
      t.timestamps
    end
  end
end
