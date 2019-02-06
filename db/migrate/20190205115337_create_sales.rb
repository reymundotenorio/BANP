class CreateSales < ActiveRecord::Migration[5.2]
  def change
    create_table :sales do |t|
      t.datetime :sale_datetime
      t.string :status, default: "ordered", null: false # ordered, invoiced, delivered, returned
      t.string :delivery_status, default: "in_queue", null: false # in_queue, invoiced, on_the_way, delivered, returned
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
