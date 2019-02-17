class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :company
      t.string :email, null: false
      t.string :phone, limit: 14, null: false, unique: true # Phone number format (000) 000-0000
      t.string :zipcode, null: false, limit: 5
      t.string :address, null: false
      t.boolean :state, null: false, default: true

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_index :customers, :email, unique: true
    # add_index :customers, :phone, unique: true
    add_index :customers, :slug, unique: true
  end
end
