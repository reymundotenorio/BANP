class CreateSaleDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :sale_details do |t|
      t.decimal :price, null: false, precision: 8, scale: 2
      t.integer :quantity, null: false
      t.string :status # returned

      # t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_reference :sale_details, :sale, index: true, foreign_key: true
    add_reference :sale_details, :product, index: true, foreign_key: true

    add_index :sale_details, :slug, unique: true
  end
end
