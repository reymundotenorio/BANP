class CreatePurchaseDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_details do |t|
      t.decimal :price, null: false, precision: 8, scale: 2
      t.integer :quantity, null: false
      t.integer :stock, null: false
      t.string :status # returned
      t.boolean :state, default: true, null: false

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_reference :purchase_details, :purchase, index: true, foreign_key: true
    add_reference :purchase_details, :product, index: true, foreign_key: true 

    add_index :purchase_details, :slug, unique: true
  end
end
