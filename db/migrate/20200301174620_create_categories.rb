class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :slug, null: false
      t.string :color, default: "000000"

      t.timestamps
    end
  end
end
