class CreateCartDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :cart_details do |t|
      t.integer :quantity, default: 0, null: false
      t.boolean :state, default: true, null: false
      t.timestamps # create_at & update_at
    end

    add_reference :cart_details, :cart, index: true, foreign_key: true
    add_reference :cart_details, :product, index: true, foreign_key: true
  end
end
