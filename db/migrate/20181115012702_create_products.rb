class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name, null: false, unique: true
      t.string :name_spanish, null: false, unique: true
      t.string :barcode, null: false
      t.decimal :price, null: false, precision: 8, scale: 2
      t.integer :stock, null: false, default: 0
      t.string :content
      t.string :content_spanish
      t.string :description
      t.string :description_spanish
      t.string :recipes
      t.string :recipes_spanish
      t.boolean :state, null: false, default: true

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_reference :products, :category, index: true, foreign_key: true

    # add_index :products, :name, unique: true
    # add_index :products, :name_spanish, unique: true
    add_index :products, :barcode, unique: true
    add_index :products, :slug, unique: true
  end
end
