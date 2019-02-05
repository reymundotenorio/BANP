class CreateSales < ActiveRecord::Migration[5.2]
  def change
    create_table :sales do |t|
      t.string :status, default: "ordered", null: false # ordered, invoiced, returned
      t.decimal :discount, null: false, precision: 8, scale: 2
      t.string :observations
      t.boolean :state, default: true, null: false
      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_reference :sales, :customer, index: true, foreign_key: true
    add_reference :sales, :user, index: true, foreign_key: true

    add_index :sales, :slug, unique: true
  end
end
