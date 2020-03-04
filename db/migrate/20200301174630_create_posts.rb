class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.references :user, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :comments_count, default: 0

      t.timestamps
    end
    add_index :posts, :title
  end
end
