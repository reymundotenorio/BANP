class CreateSales < ActiveRecord::Migration[5.2]
  def change
    create_table :sales do |t|
      t.datetime :sale_datetime, null: false #, default: -> { "CURRENT_TIMESTAMP" }
      t.string :status, null: false #, default: "ordered" # pending, ordered, invoiced, shipped, delivered, returned, price_list ## shipped and delivered for orders
      t.string :delivery_status, null: false, default: "in_queue" # in_queue, shipped, delivered, returned
      t.decimal :discount, null: false, precision: 8, scale: 2, default: 0
      t.string :payment_method, null: false # Cash, PayPal, Stripe, Card
      t.string :payment_reference, null: false # Paypal or Stripe Reference Code
      t.boolean :paid, null: false
      t.string :observations
      t.boolean :state, null: false, default: true
      t.boolean :delivery_confirmed, null: false, default: false

      # t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_reference :sales, :customer, index: true, foreign_key: true
    add_reference :sales, :employee, index: true, foreign_key: true

    # add_index :sales, :slug, unique: true
  end
end
