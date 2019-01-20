class CreatePurchases < ActiveRecord::Migration[5.2]
  def change
    create_table :purchases do |t|
      t.string :receipt_number, null: false, unique: true
      t.string :status, default: "ordered", null: false # ordered, received, returned
      t.boolean :state, default: true, null: false
      # Discount
      # Total

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_reference :purchases, :provider, index: true, foreign_key: true
    add_reference :purchases, :user, index: true, foreign_key: true
    
    add_index :purchases, :slug, unique: true
  end
end
