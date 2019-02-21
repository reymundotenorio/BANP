class CreatePurchases < ActiveRecord::Migration[5.2]
  def change
    create_table :purchases do |t|
      t.datetime :purchase_datetime, null: false #, default: -> { "CURRENT_TIMESTAMP" }
      t.string :receipt_number, null: false
      t.string :status, null: false , default: "ordered" # ordered, received, returned
      t.decimal :discount, null: false, precision: 8, scale: 2, default: 0.00
      t.string :observations
      t.boolean :state, null: false, default: true

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_reference :purchases, :provider, index: true, foreign_key: true
    add_reference :purchases, :employee, index: true, foreign_key: true

    add_index :purchases, :slug, unique: true
  end
end 
