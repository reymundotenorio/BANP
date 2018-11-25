class CreateCarts < ActiveRecord::Migration[5.2]
  def change
    create_table :carts do |t|
      t.timestamps # create_at & update_at
    end

    add_reference :carts, :costumer, index: true, foreign_key: true
  end
end
