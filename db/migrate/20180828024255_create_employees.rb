class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone, limit: 14, unique: true # Phone number format (000) 000-0000
      t.string :role, null: false
      t.boolean :state, null: false, default: true

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_index :employees, :email, unique: true
    # add_index :employees, :phone, unique: true
    add_index :employees, :slug, unique: true
  end
end
