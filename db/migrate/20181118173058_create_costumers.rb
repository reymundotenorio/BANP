class CreateCostumers < ActiveRecord::Migration[5.2]
  def change
    create_table :costumers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :company
      t.string :email, null: false
      t.string :phone, limit: 14, null: false, unique: true # Phone number format (000) 000-0000
      t.string :address, null: false
      t.boolean :state, default: true, null: false

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_index :costumers, :email, unique: true
    # add_index :costumers, :phone, unique: true
    add_index :costumers, :slug, unique: true
  end
end
