class CreatePostCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :post_categories do |t|
      t.references :category, foreign_key: true
      t.references :post, foreign_key: true

      t.timestamps
    end
    add_index :post_categories, [:category_id, :post_id], unique: true
  end
end
